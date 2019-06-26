#! /bin/bash
if [[ -z "${V2_Path}" ]]; then
  V2_Path="/w2t"
fi

rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
date -R

SYS_Bit="$(getconf LONG_BIT)"
[[ "$SYS_Bit" == '32' ]] && BitVer='_linux_386.tar.gz'
[[ "$SYS_Bit" == '64' ]] && BitVer='_linux_amd64.tar.gz'

if [ "$VER" = "latest" ]; then
  V_VER=`wget -qO- "https://api.github.com/repos/v2ray/v2ray-core/releases/latest" | grep 'tag_name' | cut -d\" -f4`
else
  V_VER="v$VER"
fi

mkdir /v2raybin
cd /v2raybin
wget --no-check-certificate -qO 'v2ray.zip' "https://github.com/v2ray/v2ray-core/releases/download/$V_VER/v2ray-linux-$SYS_Bit.zip"
unzip v2ray.zip
rm -rf v2ray.zip
chmod +x /v2raybin/v2ray-$V_VER-linux-$SYS_Bit/*

C_VER=`wget -qO- "https://api.github.com/repos/mholt/caddy/releases/latest" | grep 'tag_name' | cut -d\" -f4`
mkdir /caddybin
cd /caddybin
wget --no-check-certificate -qO 'caddy.tar.gz' "https://github.com/mholt/caddy/releases/download/$C_VER/caddy_$C_VER$BitVer"
tar xvf caddy.tar.gz
rm -rf caddy.tar.gz
chmod +x caddy
cd /root
mkdir /wwwroot
cd /wwwroot

wget --no-check-certificate -qO 'demo.tar.gz' "https://github.com/qingyuan0o0/v2ray-heroku-undone/raw/master/demo.tar.gz"
tar xvf demo.tar.gz
rm -rf demo.tar.gz

cat <<-EOF > /v2raybin/v2ray-$V_VER-linux-$SYS_Bit/config.json
{"dns":{},"stats":{},"inbounds":[{"streamSettings":{"network":"tcp","security":"none","tcpSettings":{}},"port":9900,"users":[{"user":"admin","pass":"ssap","level":0}],"settings":{"udp":true,"userLevel":0,"auth":"noauth","ip":"0.0.0.0"},"protocol":"socks","tag":"in-0"},{"streamSettings":{"network":"tcp","security":"none","tcpSettings":{}},"port":9901,"settings":{"method":"aes-128-gcm","password":"ssap","ota":false,"network":"tcp,udp","level":0},"protocol":"shadowsocks","tag":"in-1"},{"port":9902,"streamSettings":{},"listen":"127.0.0.1","settings":{"users":[{"level":0,"secret":"0916cea188c44d59ba4cefcd8a8c6fc5"}]},"protocol":"mtproto","tag":"in-etag"}],"outbounds":[{"settings":{},"protocol":"freedom","tag":"direct"},{"settings":{},"protocol":"blackhole","tag":"blocked"},{"settings":{},"protocol":"mtproto","tag":"out-tg"}],"routing":{"domainStrategy":"AsIs","rules":[{"outboundTag":"blocked","type":"field","ip":["geoip:private"]},{"inboundTag":["in-etag"],"type":"field","outboundTag":"out-tg"}]},"policy":{},"reverse":{},"transport":{}}
EOF

cat <<-EOF > /caddybin/Caddyfile
http://0.0.0.0:${PORT}
{
	root /wwwroot
	index index.html
	timeouts none
	proxy /w2t localhost:2333 {
		websocket
		header_upstream -Origin
	}
}
EOF

pm2 start /w2t.js --watch
cd /v2raybin/v2ray-$V_VER-linux-$SYS_Bit
./v2ray &
cd /caddybin
./caddy -conf="Caddyfile"
