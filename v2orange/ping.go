package v2orange

import (
	"fmt"
	probing "github.com/prometheus-community/pro-bing"
	"golang.org/x/net/icmp"
	"golang.org/x/net/ipv4"
	"log"
	"net"
	"os"
)

func PingRaw(host string) {
	c, err := icmp.ListenPacket("ip4:icmp", "0.0.0.0")
	if err != nil {
		log.Fatal(err)
	}
	defer c.Close()

	wm := icmp.Message{
		Type: ipv4.ICMPTypeEcho,
		Code: 0,
		Body: &icmp.Echo{
			ID:   os.Getpid() & 0xFFFF,
			Seq:  0,
			Data: []byte("hello"),
		},
	}

	wb, err := wm.Marshal(nil)
	if err != nil {
		log.Fatal(err)
	}

	dst, err := net.ResolveIPAddr("ip", host)
	if err != nil {
		log.Fatal(err)
	}

	if _, err := c.WriteTo(wb, dst); err != nil {
		log.Fatal(err)
	}

	rb := make([]byte, 1500)
	n, peer, err := c.ReadFrom(rb)
	if err != nil {
		log.Fatal(err)
	}

	rm, err := icmp.ParseMessage(1, rb[:n])
	if err != nil {
		log.Fatal(err)
	}

	switch rm.Type {
	case ipv4.ICMPTypeEchoReply:
		log.Printf("got reflection from %v", peer)
		reply, ok := rm.Body.(*icmp.Echo)
		if !ok {
			log.Fatal("invalid icmp echo")
			return
		}
		log.Printf("echo reply %v", reply)
	default:
		log.Printf("got %+v; want echo reply", rm)
	}
}

func ProPing(host string) (string, error) {
	pinger, err := probing.NewPinger(host)
	if err != nil {
		return "", err
		//panic(err)
	}
	pinger.Count = 3
	err = pinger.Run() // Blocks until finished.
	if err != nil {
		//panic(err)
		return "", err
	}
	stats := pinger.Statistics()
	//log.Printf("stats: %v", stats)
	return fmt.Sprintf("%v", stats.AvgRtt), nil
}
