package v2orange

import (
	"context"
	"errors"
	"github.com/eycorsican/go-tun2socks/core"
	vcore "github.com/v2fly/v2ray-core/v5"
	vproxyman "github.com/v2fly/v2ray-core/v5/app/proxyman"
	vbytespool "github.com/v2fly/v2ray-core/v5/common/bytespool"
	vsession "github.com/v2fly/v2ray-core/v5/common/session"
	"github.com/v2fly/v2ray-core/v5/infra/conf/mergers"
	"strings"
	"time"
	"v2orange/v2ray"
)

type PacketFlow interface {
	WritePacket(packet []byte)
}

var lwipStack core.LWIPStack

func InputPacket(data []byte) {
	lwipStack.Write(data)
}

var vInst *vcore.Instance

func StartV2Ray(packetFlow PacketFlow, configBytes []byte) error {
	if vInst != nil {
		return nil
	}

	if packetFlow != nil {
		lwipStack = core.NewLWIPStack()

		core.SetBufferPool(vbytespool.GetPool(core.BufSize))

		vInst, err := vcore.StartInstance(vcore.FormatJSON, configBytes)
		if err != nil {
			//log.Fatalf("start V instance failed: %v", err)
			return err
		}

		sniffingConfig := &vproxyman.SniffingConfig{
			Enabled:             true,
			DestinationOverride: strings.Split("tls,http", ","),
		}
		ctx := contextWithSniffingConfig(context.Background(), sniffingConfig)
		core.RegisterTCPConnHandler(v2ray.NewTCPHandler(ctx, vInst))
		core.RegisterUDPConnHandler(v2ray.NewUDPHandler(ctx, vInst, 30*time.Second))

		core.RegisterOutputFn(func(data []byte) (int, error) {
			packetFlow.WritePacket(data)
			return len(data), nil
		})
		return nil
	}
	return errors.New("packetFlow should not be nil")
}

func StopV2Ray() {
	if lwipStack != nil {
		_ = lwipStack.Close()
		lwipStack = nil
	}
	if vInst != nil {
		_ = vInst.Close()
		vInst = nil
	}
}

func LoadConfig(configBytes []byte) string {
	return strings.Join(mergers.GetAllNames(), "-")
}

func contextWithSniffingConfig(ctx context.Context, c *vproxyman.SniffingConfig) context.Context {
	content := vsession.ContentFromContext(ctx)
	if content == nil {
		content = new(vsession.Content)
		ctx = vsession.ContextWithContent(ctx, content)
	}
	content.SniffingRequest.Enabled = c.Enabled
	content.SniffingRequest.OverrideDestinationForProtocol = c.DestinationOverride
	return ctx
}
