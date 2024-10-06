package manager

import (
	"encoding/binary"
	"errors"
	"log"

	pb "golangtcp/messages"

	"net"

	"google.golang.org/protobuf/proto"
)

var playerManager *PlayerManager

// Player represents a single player with some attributes
type Player struct {
	ID   int
	Name string
	Age  int
	Conn *net.Conn
}

// PlayerManager manages a list of players
type PlayerManager struct {
	players map[int]Player
	nextID  int
}

// NewPlayerManager creates a new PlayerManager
func GetPlayerManager() *PlayerManager {
	if playerManager == nil {
		playerManager = &PlayerManager{
			players: make(map[int]Player),
			nextID:  1,
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
	}

	pm.players[pm.nextID] = player
	pm.nextID++
	return player
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
	for _, player := range pm.players {
		if player.Name == name {
			continue // 자신에게는 전송하지 않음
		}

		lengthBuf := make([]byte, 4)
		binary.LittleEndian.PutUint32(lengthBuf, uint32(len(response)))

		// 메시지 길이 정보와 메시지 데이터를 결합하여 전송
		lengthBuf = append(lengthBuf, response...)
		(*player.Conn).Write(lengthBuf)
	}
}

func (pm *PlayerManager) MovePlayer(name string, x float32, y float32, z float32, rx float32, ry float32, rz float32) {
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

	for _, player := range pm.players {
		if player.Name == name {
			continue
		}

		lengthBuf := make([]byte, 4)
		binary.LittleEndian.PutUint32(lengthBuf, uint32(len(response)))
		lengthBuf = append(lengthBuf, response...)
		(*player.Conn).Write(lengthBuf)
	}
}

// GetPlayer retrieves a player by ID
func (pm *PlayerManager) GetPlayer(id int) (Player, error) {
	player, exists := pm.players[id]
	if !exists {
		return Player{}, errors.New("player not found")
	}
	return player, nil
}

// RemovePlayer removes a player by ID
func (pm *PlayerManager) RemovePlayer(id int) error {
	if _, exists := pm.players[id]; !exists {
		return errors.New("player not found")
	}
	delete(pm.players, id)
	return nil
}

// ListPlayers returns all players in the manager
func (pm *PlayerManager) ListPlayers() []Player {
	playerList := []Player{}
	for _, player := range pm.players {
		playerList = append(playerList, player)
	}
	return playerList
}
