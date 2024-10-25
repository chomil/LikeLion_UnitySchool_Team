package main

import (
	"encoding/binary"
	"fmt"
	"log"
	"net"

	pb "golangtcp/messages" //golangtcp는 go.mod에 있는 모듈의 이름
	co "golangtcp/packages/constants"

	"google.golang.org/protobuf/proto"

	mg "golangtcp/packages/manager"
)

func main() {

	listener, err := net.Listen("tcp", ":8888")
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}
	defer listener.Close()
	fmt.Println("Server is listening on :8888")

	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Printf("Failed to accept connection: %v", err)
			continue
		}
		go handleConnection(conn)
	}
}

func handleConnection(conn net.Conn) {
	defer conn.Close()
	for {
		// 메시지 길이를 먼저 읽습니다 (4바이트)
		lengthBuf := make([]byte, 4)
		_, err := conn.Read(lengthBuf)
		if err != nil {
			log.Printf("Failed to read message length: %v", err)
			return
		}
		length := binary.LittleEndian.Uint32(lengthBuf)

		// 메시지 타입을 먼저 읽습니다 (1바이트)
		typeBuf := make([]byte, 1)
		_, err = conn.Read(typeBuf)
		if err != nil {
			log.Printf("Failed to read message type: %v", err)
			return
		}
		messageType := typeBuf[0]

		// 메시지 본문을 읽습니다
		messageBuf := make([]byte, length-1) // 타입 바이트 제외
		_, err = conn.Read(messageBuf)
		if err != nil {
			log.Printf("Failed to read message body: %v", err)
			return
		}

		// 메시지 처리
		switch messageType {
		case co.GameMessageType:
			gameMessage := &pb.GameMessage{}
			err = proto.Unmarshal(messageBuf, gameMessage)
			if err != nil {
				log.Printf("Failed to unmarshal GameMessage: %v", err)
				continue
			}
			processMessage(gameMessage, &conn)
		case co.MatchingMessageType:
			matchingMessage := &pb.MatchingMessage{}
			err = proto.Unmarshal(messageBuf, matchingMessage)
			if err != nil {
				log.Printf("Failed to unmarshal MatchingMessage: %v", err)
				continue
			}
			processMatchingMessage(matchingMessage, &conn)
		default:
			log.Printf("Unknown message type: %v", messageType)
		}

	}
}

func processMessage(message *pb.GameMessage, conn *net.Conn) {
	switch msg := message.Message.(type) {
	case *pb.GameMessage_PlayerPosition:
		pos := msg.PlayerPosition
		//fmt.Println("Position : ", pos.X, pos.Y, pos.Z, msg.PlayerPosition.PlayerId) //확인용 로그
		//fmt.Println("Rotation : ", pos.Rx, pos.Ry, pos.Rz)                           //확인용 로그
		mg.GetPlayerManager().MovePlayer(pos.PlayerId, pos.X, pos.Y, pos.Z, pos.Rx, pos.Ry, pos.Rz)
	case *pb.GameMessage_Chat:
		chat := msg.Chat
		mg.GetChatManager().Broadcast(chat.Sender, chat.Content)
	case *pb.GameMessage_Login:
		playerId := msg.Login.PlayerId
		fmt.Println(playerId)
		playerManager := mg.GetPlayerManager()
		playerManager.AddPlayer(playerId, 0, conn)
	case *pb.GameMessage_PlayerAnimState:
		anim := msg.PlayerAnimState
		//fmt.Println(anim.PlayerAnimState) //확인용 로그
		mg.GetPlayerManager().SendPlayerAnimation(anim.PlayerId, anim.PlayerAnimState, anim.SpeedForward, anim.SpeedRight)
	case *pb.GameMessage_Logout:
		playerId := msg.Logout.PlayerId
		playerManager := mg.GetPlayerManager()
		playerManager.RemovePlayer(playerId)
		fmt.Println("Logout ", playerId)
	case *pb.GameMessage_RaceFinish:
		finish := msg.RaceFinish
		fmt.Printf("Player %s finished the race at time %d\n", finish.PlayerId, finish.FinishTime)
		// 여기에 레이스 완주 처리 로직 추가
		mg.GetPlayerManager().PlayerFinishedRace(finish.PlayerId, finish.FinishTime)
	case *pb.GameMessage_PlayerCostume:
		costume := msg.PlayerCostume
		fmt.Printf("Player %s , %d, %s\n", costume.PlayerId, costume.PlayerCostumeType, costume.PlayerCostumeName)
		mg.GetPlayerManager().SendPlayerCostume(costume.PlayerId, costume.PlayerCostumeType, costume.PlayerCostumeName)
	case *pb.GameMessage_RaceEnd:
		raceEnd := msg.RaceEnd
		fmt.Printf("Race ended by player %s\n", raceEnd.PlayerId)
		mg.GetPlayerManager().HandleRaceEnd(raceEnd.PlayerId)
	case *pb.GameMessage_SpawnExistingPlayer:
		playerId := msg.SpawnExistingPlayer.PlayerId
		newPlayer, exists := mg.GetPlayerManager().FindPlayerByName(playerId)
		if !exists {
			fmt.Println("Not found player", playerId)
		}
		mg.GetPlayerManager().SendExistingPlayersToNewPlayer(*newPlayer)

	default:
		panic(fmt.Sprintf("unexpected messages.isGameMessage_Message: %#v", msg))
	}
}

func processMatchingMessage(message *pb.MatchingMessage, conn *net.Conn) {
	if message.Matching == nil {
		log.Printf("Received a MatchingMessage with nil Matching field")
		return // 패닉을 방지하고 함수 종료
	}
	switch msg := message.Matching.(type) {
	case *pb.MatchingMessage_MatchingRequest:
		playerID := msg.MatchingRequest.PlayerId
		if msg.MatchingRequest.Waiting {
			mg.GetMatchingManager().AddPlayer(playerID, *conn)
			fmt.Println("Matching Game", playerID)
		} else {
			mg.GetMatchingManager().RemovePlayer(playerID)
			fmt.Println("Leave Matching", playerID)
		}
	case *pb.MatchingMessage_MatchingResponse:
		// 매칭 응답 처리 로직
	case *pb.MatchingMessage_MatchingUpdate:
		// 매칭 업데이트 처리 로직
	default:
		panic(fmt.Sprintf("unexpected messages.isMatchingMessage_Message: %#v", msg))
	}
}
