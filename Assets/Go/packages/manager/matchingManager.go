package manager

import (
	"encoding/binary"
	"fmt"
	"log"
	"math/rand"
	"net"
	"sync"
	"time"

	pb "golangtcp/messages"
	co "golangtcp/packages/constants"

	"google.golang.org/protobuf/proto"
)

const (
	minPlayersPerRace = 5  //레이스에 참여하는 최소 인원 수
	maxPlayersPerRace = 30 //레이스에 참여하는 최대 인원 수
)

var RaceMaps = []string{
	"Race01",
	"Race02",
	"Race03",
	"Race04",
}

var TeamMaps = []string{
	"Race01",
	"Race02",
	"Race03",
	"Race04",
}

var FinalsMaps = []string{
	"Final01",
}

var matchingManager *MatchingManager

// MatchingPlayer는 매칭 시스템에서 사용할 플레이어 정보를 나타냅니다.
type MatchingPlayer struct {
	ID   string   // 플레이어 ID
	Addr string   // 플레이어의 네트워크 주소
	Conn net.Conn // 플레이어의 연결
	//Ready bool     // 플레이어의 준비 상태
}

// MatchingManager는 매칭 시스템을 관리하는 구조체입니다.
type MatchingManager struct {
	Players  map[string]*MatchingPlayer // 플레이어 목록
	mutex    sync.Mutex                 // 동기화용 뮤텍스
	starting bool
}

func GetMatchingManager() *MatchingManager {
	if matchingManager == nil {
		matchingManager = NewMatchingManager()
	}
	return matchingManager
}

// NewMatchingManager는 새로운 매칭 매니저를 초기화합니다.
func NewMatchingManager() *MatchingManager {
	return &MatchingManager{
		Players: make(map[string]*MatchingPlayer),
	}
}

// AddPlayer는 새로운 플레이어를 매칭열에 추가합니다.
func (m *MatchingManager) AddPlayer(id string, conn net.Conn) {
	m.mutex.Lock()
	defer m.mutex.Unlock()

	m.Players[id] = &MatchingPlayer{
		ID:   id,
		Addr: conn.RemoteAddr().String(),
		Conn: conn,
		//Ready: false,
	}
	log.Printf("Player added to matching: %s", id)
	m.SendMatchingStatus() // 플레이어들에게 현재 매칭현황 전송

	if len(m.Players) >= 1 && !m.starting {
		m.StartCountdown()
	}
}

// RemovePlayer는 매칭에서 플레이어를 제거합니다.
func (m *MatchingManager) RemovePlayer(id string) {
	m.mutex.Lock()
	defer m.mutex.Unlock()
	if _, ok := m.Players[id]; ok {
		delete(m.Players, id)
		log.Printf("Player removed from matching: %s", id)
	}
	m.SendMatchingStatus()
}

func (m *MatchingManager) StartCountdown() {
	m.starting = true
	go func() {
		ticker := time.NewTicker(500 * time.Millisecond) // 0.5초마다 체크
		defer ticker.Stop()
		timeout := time.After(10 * time.Second) // 10초 타임아웃 설정

		for {
			select {
			case <-ticker.C:
				if len(m.Players) >= maxPlayersPerRace { // 필요한 플레이어 수가 채워졌을 때
					m.StartMatch()
					return // goroutine 종료
				}
			case <-timeout:
				if len(m.Players) >= minPlayersPerRace {
					// 시간이 만료됐지만 플레이어 수가 충분할 경우
					m.StartMatch()
				} else {
					// 시간이 만료되고 플레이어가 충분하지 않을 경우
					for _, player := range m.Players {
						fmt.Printf("Not enough players to start the game for player %s\n", player.ID)
					}
					// 대기열 초기화
					m.Players = make(map[string]*MatchingPlayer)
					m.starting = false
				}
				return // goroutine 종료
			}
		}
	}()
}

// StartMatch는 매칭이 성공적으로 이루어졌을 때 호출됩니다.
func (m *MatchingManager) StartMatch() {
	var GameMaps = SetRaceMaps() //레이스할 맵 세팅

	//초기화필요
	playerManager := GetPlayerManager()
	InitPlayerManager()

	matchingSeed := rand.Int31()

	// 매칭 시작 로직 구현
	for _, player := range m.Players {
		message := &pb.MatchingMessage{
			Matching: &pb.MatchingMessage_MatchingResponse{
				MatchingResponse: &pb.MatchingResponse{
					GameServerAddress: "",
					Success:           true,
					MapName:           GameMaps,
					MatchingSeed:      matchingSeed,
				},
			},
		}

		data, err := proto.Marshal(message)
		if err != nil {
			log.Printf("Error marshaling MatchingResponse: %v", err)
			continue
		}

		lengthBuf := make([]byte, 5)                                    // 메시지 길이와 타입을 포함하기 위해 5바이트로 설정
		lengthBuf[0] = co.MatchingMessageType                           // 메시지 타입 설정
		binary.LittleEndian.PutUint32(lengthBuf[1:], uint32(len(data))) // 길이 설정

		log.Printf("Sending MatchingResponse to player %s: Type: %d, Length: %d", player.ID, lengthBuf[0], binary.LittleEndian.Uint32(lengthBuf[1:]))

		// 메시지 길이 정보와 메시지 데이터를 결합하여 전송
		lengthBuf = append(lengthBuf, data...) // 전체 메시지 생성

		// 연결된 플레이어에게 전송
		_, err = player.Conn.Write(lengthBuf)
		if err != nil {
			log.Printf("Error sending MatchingResponse to %s: %v", player.ID, err)
		} else {
			log.Printf("Successfully sent MatchingResponse to player %s", player.ID)
		}

		playerManager.AddMatchedPlayer(player.ID)
	}

	//매칭 플레이어 수에 따라 플레이어 매니저 통과인원 초기화

	percent := 0.7 //70%씩 통과
	if len(playerManager.matchedPlayers) <= 5 {
		percent = 0.8 //5명 이하로 남으면 80% 통과
	}
	playerManager.qualifyLimits[0] = int(float64(len(playerManager.matchedPlayers)) * percent)
	playerManager.maxQualifiedPlayers = playerManager.qualifyLimits[0]
	playerManager.BroadcastPlayerCount()

	//대기열 초기화
	m.Players = make(map[string]*MatchingPlayer)
	m.starting = false
}

func SetRaceMaps() []string {
	temp := make(map[int]string)

	//레이스 맵 중복없이 뽑기
	for len(temp) < 3 {
		idx := rand.Intn(len(RaceMaps))
		temp[idx] = RaceMaps[idx]
	}

	var res []string

	//string 배열에 할당
	for idx := range temp {
		res = append(res, RaceMaps[idx])
	}
	//결승전 맵 선정
	res = append(res, FinalsMaps[rand.Intn(len(FinalsMaps))])

	return res
}

func (m *MatchingManager) SendMatchingStatus() {
	for _, player := range m.Players {
		message := &pb.MatchingMessage{
			Matching: &pb.MatchingMessage_MatchingUpdate{
				MatchingUpdate: &pb.MatchingUpdate{
					CurrentPlayers:  int32(len(m.Players)),
					RequiredPlayers: maxPlayersPerRace,
				},
			},
		}

		data, err := proto.Marshal(message)
		if err != nil {
			log.Printf("Error marshaling MatchingResponse: %v", err)
			continue
		}

		lengthBuf := make([]byte, 5)                                    // 메시지 길이와 타입을 포함하기 위해 5바이트로 설정
		lengthBuf[0] = co.MatchingMessageType                           // 메시지 타입 설정
		binary.LittleEndian.PutUint32(lengthBuf[1:], uint32(len(data))) // 길이 설정

		log.Printf("Sending MatchingResponse to player %s: Type: %d, Length: %d", player.ID, lengthBuf[0], binary.LittleEndian.Uint32(lengthBuf[1:]))

		// 메시지 길이 정보와 메시지 데이터를 결합하여 전송
		lengthBuf = append(lengthBuf, data...) // 전체 메시지 생성

		// 연결된 플레이어에게 전송
		_, err = player.Conn.Write(lengthBuf)
		if err != nil {
			log.Printf("Error sending MatchingResponse to %s: %v", player.ID, err)
		} else {
			log.Printf("Successfully sent MatchingResponse to player %s", player.ID)
		}
	}
}
