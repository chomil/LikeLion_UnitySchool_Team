package main

import (
	"encoding/binary"
	"fmt"
	"io"
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

const maxMessageSize = 1024 * 1024 // 1MB 메시지 크기 제한

func handleConnection(conn net.Conn) {
	defer conn.Close()
	for {
		// 메시지 길이 읽기 (4바이트)
		lengthBuf := make([]byte, 4)
		_, err := io.ReadFull(conn, lengthBuf)
		if err != nil {
			log.Printf("Failed to read message length: %v", err)
			return
		}
		length := binary.LittleEndian.Uint32(lengthBuf)

		// 메시지 크기 검증
		if length > maxMessageSize || length < 1 { // 최소 1바이트 이상이어야 함
			log.Printf("Invalid message size: %d bytes", length)
			return
		}

		// 메시지 타입 읽기 (1바이트)
		typeBuf := make([]byte, 1)
		_, err = io.ReadFull(conn, typeBuf)
		if err != nil {
			log.Printf("Failed to read message type: %v", err)
			return
		}
		messageType := typeBuf[0]

		// 메시지 본문 읽기
		messageBuf := make([]byte, length-1)
		_, err = io.ReadFull(conn, messageBuf)
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
		mg.GetMatchingManager().RemovePlayer(playerId) //매칭 대기열에서도 제거
		fmt.Println("Logout ", playerId)
	case *pb.GameMessage_RaceFinish:
		finish := msg.RaceFinish
		fmt.Printf("Player %s finished the race at time %d\n", finish.PlayerId, finish.FinishTime)
		// 여기에 레이스 완주 처리 로직 추가
		mg.GetPlayerManager().PlayerFinishedRace(finish.PlayerId, finish.FinishTime, finish.Survive)
	case *pb.GameMessage_PlayerCostume:
		costume := msg.PlayerCostume
		//fmt.Printf("Player %s , %d, %s, %s\n", costume.PlayerId, costume.PlayerCostumeType, costume.PlayerCostumeName, costume.OtherPlayerId)
		mg.GetPlayerManager().SendPlayerCostume(costume.PlayerId, costume.PlayerCostumeType, costume.PlayerCostumeName, costume.OtherPlayerId)
	case *pb.GameMessage_RaceEnd:
		raceEnd := msg.RaceEnd
		fmt.Printf("Race ended by player %s\n", raceEnd.PlayerId)
		//레이스 엔드 메시지는 클라에서 받아오지 말고 서버에서 클라로 보내줘야함
		//mg.GetPlayerManager().HandleRaceEnd(raceEnd.PlayerId)
	case *pb.GameMessage_PlayerCount:
		// 클라이언트로부터 플레이어 카운트 요청이 올 경우 처리
		playerManager := mg.GetPlayerManager()
		playerManager.BroadcastPlayerCount()
	case *pb.GameMessage_SpectatorState:
		spectatorState := msg.SpectatorState
		mg.GetPlayerManager().SetPlayerSpectating(
			spectatorState.PlayerId,
			spectatorState.TargetPlayerId,
		)
		fmt.Printf(
			"Player %s is now spectating player %s\n",
			spectatorState.PlayerId,
			spectatorState.TargetPlayerId,
		)
	case *pb.GameMessage_SpawnExistingPlayer:
		playerId := msg.SpawnExistingPlayer.PlayerId
		newPlayer, exists := mg.GetPlayerManager().FindPlayerByName(playerId)
		if !exists {
			fmt.Println("Not found player", playerId)
		} else {
			mg.GetPlayerManager().SendExistingPlayersToNewPlayer(*newPlayer)
		}

	case *pb.GameMessage_PlayerGrabInfo:
		playerId := msg.PlayerGrabInfo.PlayerId
		isGrabbing := msg.PlayerGrabInfo.CurrentGrab
		mg.GetPlayerManager().SendGrabbedPlayer(playerId, isGrabbing)
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
			// 매칭 취소할 때 플레이어 카운트 업데이트
			mg.GetPlayerManager().BroadcastPlayerCount()
		}
	case *pb.MatchingMessage_MatchingResponse:
		// 매칭 응답 처리 로직
	case *pb.MatchingMessage_MatchingUpdate:
		//mg.GetMatchingManager().SendMatchingStatus()
	default:
		panic(fmt.Sprintf("unexpected messages.isMatchingMessage_Message: %#v", msg))
	}
}
