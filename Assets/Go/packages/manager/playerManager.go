package manager

import (
	"encoding/binary"
	"errors"
	"fmt"
	"log"

	pb "golangtcp/messages"
	co "golangtcp/packages/constants"

	"net"

	"google.golang.org/protobuf/proto"
)

var playerManager *PlayerManager

// Player represents a single player with some attributes
type Player struct {
	ID               int
	Name             string
	Age              int
	Conn             *net.Conn
	X                float32
	Y                float32
	Z                float32
	Rx               float32
	Ry               float32
	Rz               float32
	FinishTime       int64
	IsSpectating     bool
	SpectatingTarget string
}

// PlayerManager manages a list of players

type PlayerManager struct {
	players                   map[int]*Player
	nextID                    int
	activePlayersForNextRound map[string]bool
	maxQualifiedPlayers       int
	matchedPlayers            map[int]*Player
	matchID                   int
}

// NewPlayerManager creates a new PlayerManager

func GetPlayerManager() *PlayerManager {
	if playerManager == nil {
		playerManager = &PlayerManager{
			players:                   make(map[int]*Player),
			nextID:                    1,
			activePlayersForNextRound: make(map[string]bool),
			maxQualifiedPlayers:       10,
			matchedPlayers:            make(map[int]*Player),
			matchID:                   1,
		}
	}
	return playerManager
}

// AddPlayer adds a new player to the manager
func (pm *PlayerManager) AddPlayer(name string, age int, conn *net.Conn) Player {
	player := Player{
		ID:   pm.nextID,
		Name: name,
		Age:  age,
		Conn: conn,
		X:    0,
		Y:    0,
		Z:    0,
		Rx:   0,
		Ry:   0,
		Rz:   0,
	}

	pm.players[pm.nextID] = &player
	pm.nextID++

	//pm.SpawnNewPlayerInfo(player)
	//pm.SendExistingPlayersToNewPlayer(player)

	return player
}

func (pm *PlayerManager) AddMatchedPlayer(name string) {
	player, exists := pm.FindPlayerByName(name)
	if !exists {
		fmt.Println("Not found player")
	}

	pm.matchedPlayers[pm.matchID] = player
	pm.matchID++

	//pm.SpawnNewPlayerInfo(*player)
	//pm.SendExistingPlayersToNewPlayer(*player)
}

// 로그인 시 내 정보를 다른 플레이어들에게 전송해서 나를 스폰하도록 한다.
// func (pm *PlayerManager) SpawnNewPlayerInfo(newPlayer Player) {
func (pm *PlayerManager) SpawnNewPlayerInfo(newPlayer Player) {
	gameMessage := &pb.GameMessage{
		Message: &pb.GameMessage_SpawnPlayer{
			SpawnPlayer: &pb.SpawnPlayer{
				PlayerId: newPlayer.Name,
				X:        0,
				Y:        0,
				Z:        0,
				Rx:       0,
				Ry:       0,
				Rz:       0,
			},
		},
	}

	// 직렬화
	response, err := proto.Marshal(gameMessage)
	if err != nil {
		log.Printf("Failed to marshal response: %v", err)
		return
	}

	// 다른 플레이어들에게 전송
	for _, player := range pm.matchedPlayers {
		if player.Name == newPlayer.Name {
			continue // 자신에게는 전송하지 않음
		}

		lengthBuf := make([]byte, 5)      // 메시지 길이와 타입을 포함하기 위해 5바이트로 설정
		lengthBuf[0] = co.GameMessageType // 메시지 타입 설정
		len := uint32(len(response))
		binary.LittleEndian.PutUint32(lengthBuf[1:], len)

		// 메시지 길이 정보와 메시지 데이터를 결합하여 전송
		lengthBuf = append(lengthBuf, response...)
		fmt.Println("spawn ", player.Name, lengthBuf)
		(*player.Conn).Write(lengthBuf)
	}
}

func (pm *PlayerManager) SendExistingPlayersToNewPlayer(newPlayer Player) {
	for _, existingPlayer := range pm.matchedPlayers {
		if existingPlayer.Name == newPlayer.Name {
			// 자신은 제외
			continue
		}

		// 기존 플레이어 정보를 새로운 유저에게 전송
		gameMessage := &pb.GameMessage{
			Message: &pb.GameMessage_SpawnExistingPlayer{
				SpawnExistingPlayer: &pb.SpawnPlayer{
					PlayerId: existingPlayer.Name,
					X:        existingPlayer.X,
					Y:        existingPlayer.Y,
					Z:        existingPlayer.Z,
					Rx:       existingPlayer.Rx,
					Ry:       existingPlayer.Ry,
					Rz:       existingPlayer.Rz,
				},
			},
		}

		response, err := proto.Marshal(gameMessage)
		if err != nil {
			log.Printf("Failed to marshal response: %v", err)
			return
		}

		// // 새로운 플레이어에게 기존 플레이어 정보 전송
		length := uint32(len(response))
		lengthBuf := make([]byte, 5)
		lengthBuf[0] = co.GameMessageType

		binary.LittleEndian.PutUint32(lengthBuf[1:], length)
		//fmt.Println("spawn ", existingPlayer.Name, lengthBuf)
		if _, err := (*newPlayer.Conn).Write(append(lengthBuf, response...)); err != nil {
			log.Printf("Failed to send player data to new player: %v", err)
		}
	}
}

func (pm *PlayerManager) SendPlayerCostume(name string, cosType int32, cosName string) {
	gameMessage := &pb.GameMessage{
		Message: &pb.GameMessage_PlayerCostume{
			PlayerCostume: &pb.CostumeMessage{
				PlayerId:          name,
				PlayerCostumeType: cosType,
				PlayerCostumeName: cosName,
			},
		},
	}
	response, err := proto.Marshal(gameMessage)
	if err != nil {
		log.Printf("Failed to marshal response: %v", err)
		return
	}

	// 다른 플레이어들에게 전송
	//	for _, player := range pm.players {
	for _, player := range pm.matchedPlayers {
		if player.Name == name {
			continue // 자신에게는 전송하지 않음
		}

		lengthBuf := make([]byte, 5)      // 메시지 길이와 타입을 포함하기 위해 5바이트로 설정
		lengthBuf[0] = co.GameMessageType // 메시지 타입 설정
		binary.LittleEndian.PutUint32(lengthBuf[1:], uint32(len(response)))
		(*player.Conn).Write(append(lengthBuf, response...))
	}
}

func (pm *PlayerManager) SendPlayerAnimation(name string, animation string, speedF float32, speedR float32) {
	// GameMessage에 PlayerAnimation 타입 추가
	gameMessage := &pb.GameMessage{
		Message: &pb.GameMessage_PlayerAnimState{
			PlayerAnimState: &pb.PlayerAnimation{
				PlayerAnimState: animation,
				PlayerId:        name,
				SpeedForward:    speedF,
				SpeedRight:      speedR,
			},
		},
	}

	// 직렬화
	response, err := proto.Marshal(gameMessage)
	if err != nil {
		log.Printf("Failed to marshal response: %v", err)
		return
	}

	// 다른 플레이어들에게 전송
	//for _, player := range pm.players {
	for _, player := range pm.matchedPlayers {
		if player.Name == name {
			continue // 자신에게는 전송하지 않음
		}

		lengthBuf := make([]byte, 5)      // 메시지 길이와 타입을 포함하기 위해 5바이트로 설정
		lengthBuf[0] = co.GameMessageType // 메시지 타입 설정
		binary.LittleEndian.PutUint32(lengthBuf[1:], uint32(len(response)))
		lengthBuf = append(lengthBuf, response...)
		(*player.Conn).Write(lengthBuf)
	}
}

func (pm *PlayerManager) MovePlayer(name string, x float32, y float32, z float32, rx float32, ry float32, rz float32) {
	player, exists := pm.FindPlayerByName(name)
	if !exists {
		log.Printf("Player not found: %s", name)
		return
	}

	// 플레이어의 위치 업데이트
	player.X = x
	player.Y = y
	player.Z = z
	player.Rx = rx
	player.Ry = ry
	player.Rz = rz

	gameMessage := &pb.GameMessage{
		Message: &pb.GameMessage_PlayerPosition{
			PlayerPosition: &pb.PlayerPosition{
				PlayerId: name,
				X:        x,
				Y:        y,
				Z:        z,
				Rx:       rx,
				Ry:       ry,
				Rz:       rz,
			},
		},
	}

	response, err := proto.Marshal(gameMessage)
	if err != nil {
		log.Printf("Failed to marshal response: %v", err)
		return
	}

	for _, player := range pm.matchedPlayers {
		//for _, player := range pm.players {
		if player.Name == name {
			continue
		}

		lengthBuf := make([]byte, 5)      // 메시지 길이와 타입을 포함하기 위해 5바이트로 설정
		lengthBuf[0] = co.GameMessageType // 메시지 타입 설정
		binary.LittleEndian.PutUint32(lengthBuf[1:], uint32(len(response)))
		(*player.Conn).Write(append(lengthBuf, response...))
	}
}

// GetPlayer retrieves a player by ID
func (pm *PlayerManager) GetPlayer(id int) (*Player, error) {
	player, exists := pm.players[id]
	if !exists {
		return nil, errors.New("player not found")
	}
	return player, nil
}

// RemovePlayer removes a player by ID
func (pm *PlayerManager) RemovePlayer(id string) error {
	player, exists := pm.FindPlayerByName(id)
	if !exists {
		log.Printf("Player not found: %s", id)
		return errors.New("Player not found")
	}
	delete(pm.players, player.ID)

	logoutPacket := &pb.GameMessage{
		Message: &pb.GameMessage_Logout{
			Logout: &pb.LogoutMessage{
				PlayerId: id,
			},
		},
	}

	response, err := proto.Marshal(logoutPacket)
	if err != nil {
		log.Printf("Failed to marshal response: %v", err)
		return errors.New("fail to send logout packet")
	}

	for _, player := range pm.players {
		if player.Name == id {
			continue // 자신에게는 전송하지 않음
		}

		lengthBuf := make([]byte, 5)      // 메시지 길이와 타입을 포함하기 위해 5바이트로 설정
		lengthBuf[0] = co.GameMessageType // 메시지 타입 설정
		binary.LittleEndian.PutUint32(lengthBuf[1:], uint32(len(response)))
		lengthBuf = append(lengthBuf, response...)
		(*player.Conn).Write(lengthBuf)
	}

	// // 이 코드를 들어온 유저를 제외한 플레이어들에게 스폰시켜달라고 한다.
	// for _, p := range pm.players {
	// 	(*p.Conn).Write(response)
	// }

	return nil
}

// ListPlayers returns all players in the manager
func (pm *PlayerManager) ListPlayers() []*Player {
	playerList := []*Player{}
	for _, player := range pm.players {
		playerList = append(playerList, player)
	}
	return playerList
}

func (pm *PlayerManager) FindPlayerByName(name string) (*Player, bool) {
	for _, player := range pm.players {
		if player.Name == name {
			return player, true // 포인터를 반환합니다.
		}
	}
	return nil, false // 찾지 못한 경우 nil과 false를 반환합니다.
}

func (pm *PlayerManager) BroadcastMessage(message *pb.GameMessage) {
	response, err := proto.Marshal(message)
	if err != nil {
		log.Printf("Failed to marshal response: %v", err)
		return
	}

	//for _, player := range pm.players {
	for _, player := range pm.matchedPlayers {
		lengthBuf := make([]byte, 5)      // 메시지 길이와 타입을 포함하기 위해 5바이트로 설정
		lengthBuf[0] = co.GameMessageType // 메시지 타입 설정
		binary.LittleEndian.PutUint32(lengthBuf[1:], uint32(len(response)))
		lengthBuf = append(lengthBuf, response...)
		(*player.Conn).Write(lengthBuf)
	}
}

func (pm *PlayerManager) PlayerFinishedRace(playerId string, finishTime int64) {
	player, exists := pm.FindPlayerByName(playerId)
	if !exists {
		log.Printf("Player not found: %s", playerId)
		return
	}

	// 이미 완주한 플레이어인지 체크
	if player.FinishTime > 0 {
		log.Printf("Player %s already finished", playerId)
		return
	}

	if len(pm.activePlayersForNextRound) < pm.maxQualifiedPlayers {
		pm.activePlayersForNextRound[playerId] = true
	}

	player.FinishTime = finishTime

	// 모든 플레이어에게 완주 정보 브로드캐스트
	finishMessage := &pb.GameMessage{
		Message: &pb.GameMessage_RaceFinish{
			RaceFinish: &pb.RaceFinishMessage{
				PlayerId:   playerId,
				FinishTime: finishTime,
			},
		},
	}

	pm.BroadcastMessage(finishMessage)

	// 모든 플레이어가 완주했거나 최대 통과 인원에 도달했는지 체크
	finishedCount := 0
	totalPlayers := len(pm.matchedPlayers)
	for _, p := range pm.matchedPlayers {
		if p.FinishTime > 0 {
			finishedCount++
		}
	}

	if finishedCount >= totalPlayers || len(pm.activePlayersForNextRound) >= pm.maxQualifiedPlayers {
		pm.HandleRaceEnd(playerId)
	}
}

func (pm *PlayerManager) HandleRaceEnd(playerId string) {

	// 이미 다음 라운드 처리가 진행 중인지 체크
	if len(pm.activePlayersForNextRound) == 0 {
		log.Printf("Race end already handled")
		return
	}

	if len(pm.activePlayersForNextRound) > 0 {
		// 새로운 플레이어 맵 생성

		newPlayers := make(map[int]*Player)
		newID := 1

		// 통과한 플레이어만 새로운 맵에 추가

		//for _, player := range pm.players {
		for _, player := range pm.matchedPlayers {
			if pm.activePlayersForNextRound[player.Name] {
				player.ID = newID // ID 재할당
				newPlayers[newID] = player
				newID++
			}
		}

		// 플레이어 목록 업데이트
		pm.players = newPlayers
		pm.nextID = newID

		// 레이스 종료 메시지 브로드캐스트
		raceEndMessage := &pb.GameMessage{
			Message: &pb.GameMessage_RaceEnd{
				RaceEnd: &pb.RaceEndMessage{
					PlayerId: playerId,
				},
			},
		}

		pm.BroadcastMessage(raceEndMessage)
		log.Printf("Race ended by player: %s, Qualified players: %d", playerId, len(newPlayers))

		pm.activePlayersForNextRound = make(map[string]bool) // 초기화

	}

	// 레이스 종료 메시지 브로드캐스트

	raceEndMessage := &pb.GameMessage{
		Message: &pb.GameMessage_RaceEnd{
			RaceEnd: &pb.RaceEndMessage{
				PlayerId: playerId,
			},
		},
	}

	pm.BroadcastMessage(raceEndMessage)

	log.Printf("Race ended by player: %s, Players remaining: %d", playerId, len(pm.players))

}

// 관전 Spectating
func (pm *PlayerManager) SetPlayerSpectating(playerId string, targetPlayerId string) {
	player, exists := pm.FindPlayerByName(playerId)
	if !exists {
		log.Printf("Player not found: %s", playerId)
		return
	}

	player.IsSpectating = true
	player.SpectatingTarget = targetPlayerId

	// 관전 상태 변경을 다른 플레이어들에게 알림
	spectatorMessage := &pb.GameMessage{
		Message: &pb.GameMessage_SpectatorState{
			SpectatorState: &pb.SpectatorStateMessage{
				PlayerId:       playerId,
				IsSpectating:   true,
				TargetPlayerId: targetPlayerId,
			},
		},
	}

	// 메시지 전송
	response, err := proto.Marshal(spectatorMessage)
	if err != nil {
		log.Printf("Failed to marshal spectator message: %v", err)
		return
	}

	// 모든 플레이어에게 브로드캐스트
	for _, player := range pm.matchedPlayers {
		lengthBuf := make([]byte, 5)
		lengthBuf[0] = co.GameMessageType
		binary.LittleEndian.PutUint32(lengthBuf[1:], uint32(len(response)))
		(*player.Conn).Write(append(lengthBuf, response...))
	}
}

// 관전 가능한 플레이어 목록 반환
func (pm *PlayerManager) GetSpectateablePlayers() []string {
	var players []string
	for _, player := range pm.matchedPlayers {
		if !player.IsSpectating { // 관전자가 아닌 플레이어만 포함
			players = append(players, player.Name)
		}
	}
	return players
}

func (pm *PlayerManager) ChangeSpectatorTarget(spectatorId string, newTargetId string) {
	player, exists := pm.FindPlayerByName(spectatorId)
	if !exists {
		return
	}

	player.SpectatingTarget = newTargetId

	// 관전 대상 변경을 알림
	spectatorMessage := &pb.GameMessage{
		Message: &pb.GameMessage_SpectatorState{
			SpectatorState: &pb.SpectatorStateMessage{
				PlayerId:       spectatorId,
				IsSpectating:   true,
				TargetPlayerId: newTargetId,
			},
		},
	}

	response, err := proto.Marshal(spectatorMessage)
	if err != nil {
		log.Printf("Failed to marshal spectator target change message: %v", err)
		return
	}

	// 관전자에게만 전송
	lengthBuf := make([]byte, 5)
	lengthBuf[0] = co.GameMessageType
	binary.LittleEndian.PutUint32(lengthBuf[1:], uint32(len(response)))
	(*player.Conn).Write(append(lengthBuf, response...))
}
