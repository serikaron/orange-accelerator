//go:build !ios && !android
// +build !ios,!android

package v2ray

import (
	_ "github.com/v2fly/v2ray-core/v5/app/commander"
	_ "github.com/v2fly/v2ray-core/v5/app/log/command"
	_ "github.com/v2fly/v2ray-core/v5/app/proxyman/command"
	_ "github.com/v2fly/v2ray-core/v5/app/stats/command"

	_ "github.com/v2fly/v2ray-core/v5/app/reverse"

	_ "github.com/v2fly/v2ray-core/v5/transport/internet/domainsocket"
)
