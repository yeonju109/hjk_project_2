# 1. stable-alpine 버전의 nginx 기본 베이스로 설정합니다.
FROM nginx:stable-alpine-slim

# 2. Asia/Seoul 시간을 설정합니다.
ENV TZ Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 3. WAS와 연결하기 위해서 conf파일 수정합니다.
# COPY conf.d/default.conf /etc/nginx/conf.d/default.conf
# COPY html /usr/share/nginx/html/

# 3. 80포트 오픈합니다.
EXPOSE 80

# 4. container 실행 시 자동으로 실행할 command. nginx 시작
CMD ["nginx", "-g", "daemon off;"]
