set -e
JAR=$(stat -c '%y' /opt/youtong/app/app.jar)
echo "jar time: $JAR"
TOKEN=$(curl -s -X POST http://127.0.0.1:3001/api/auth/login -H 'Content-Type: application/json' -d '{"username":"admin","password":"123456"}' | grep -o '"token":"[^"]*"' | head -1 | sed 's/.*:"//;s/"//')
echo "admin token len=${#TOKEN}"
CODE=$(curl -s -X POST http://127.0.0.1:3001/api/auth/sendCode -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -d '{"phone":"13900001111"}' | grep -o '"code":"[0-9]*"' | sed 's/.*:"//;s/"//')
echo "demo code=$CODE"
echo '--- phoneLogin 响应 ---'
curl -s -X POST http://127.0.0.1:3001/api/auth/phoneLogin -H 'Content-Type: application/json' -d "{\"phone\":\"13900001111\",\"code\":\"$CODE\"}"
echo
