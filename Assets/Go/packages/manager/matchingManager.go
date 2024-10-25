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
	playersPerRace = 2 //레이스에 참여하는 최대 인원 수
)

var RaceMaps = []string{
	"Race01",
	"Race02",
}

var TeamMaps = []string{
	"Race01",
	"Race02",
}

var FinalsMaps = []string{
	"Race01",
	"Race02",
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
}

func (m *MatchingManager) StartCountdown() {
	m.starting = true
	go func() {
		time.Sleep(10 * time.Second) // 30초 동안 기다림

		if len(m.Players) >= playersPerRace { //playPerRace는 원할한 테스트를 위해 3으로 설정
			//게임 시작
			m.StartMatch()
		} else {
			//매칭 실패
			for _, player := range m.Players {
				fmt.Printf("Not enough players to start the game for player %s\n", player.ID)
			}
			// 대기열 초기화
			m.Players = make(map[string]*MatchingPlayer)
			m.starting = false
		}
	}()
}

// StartMatch는 매칭이 성공적으로 이루어졌을 때 호출됩니다.
func (m *MatchingManager) StartMatch() {
	var GameMaps []string
	GameMaps = append(GameMaps, RaceMaps[rand.Intn(len(RaceMaps))])
	GameMaps = append(GameMaps, RaceMaps[rand.Intn(len(RaceMaps))])
	GameMaps = append(GameMaps, RaceMaps[rand.Intn(len(RaceMaps))])
	GameMaps = append(GameMaps, FinalsMaps[rand.Intn(len(FinalsMaps))])
	playerManager := GetPlayerManager()
	playerManager.matchedPlayers = make(map[int]*Player)

	// 매칭 시작 로직 구현
	for _, player := range m.Players {
		message := &pb.MatchingMessage{
			Matching: &pb.MatchingMessage_MatchingResponse{
				MatchingResponse: &pb.MatchingResponse{
					GameServerAddress: "",
					Success:           true,
					MapName:           GameMaps,
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

	//대기열 초기화
	m.Players = make(map[string]*MatchingPlayer)
	m.starting = false
}
