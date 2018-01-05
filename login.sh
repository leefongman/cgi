#!/bin/bash

source libs

login_ok() {
    grep -qE 'name=alice&password=abc\b' <<<"$1"
}

post_data=$(cat)
if login_ok "$post_data"; then
    login_success=1
    # 创建session数据
    mkdir -p "$session_dir"
    # 1. session文件里面要存放什么数据：客户端登录的时间戳
    session_data=$(date +%s)
    # 2. session文件的名字是什么：计算客户端的名字密码加上当前时间的sha1
    sid=$(echo "$post_data $session_data" | sha1sum | awk '{print $1}')
    session_file="$session_dir/$sid"
    echo "$session_data" > "$session_file"
else
    login_success=0
fi

# 输出头信息
echo "Content-Type: text/html"
if test "$login_success" -eq 1; then
    echo "Set-Cookie: sid=$sid; expires=$(date -R -d +1day)"
    echo "Status: 302 Found"
    echo "Location: /cgi-bin/monitor2"
fi
echo

# 输出正文
cat <<EOF
<html>
<body>
  <form method="post">
    <table>
    <tr>
      <td><label for="username">Name: </label></td>
      <td><input name="username" id="username"></td>
    </tr>
    <tr>
      <td><label for="password">Pass: </label></td>
      <td><input name="password" id="password" type="password"></td>
    </tr>
    <tr><td colspan=2><input type="submit" value="Login"></td></tr>
    <table>
  </form>
  <pre>
$(export)
  </pre>
</body>
</html>
EOF
