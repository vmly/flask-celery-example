FROM python:3.6.12-slim-buster
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 PYTHONUNBUFFERED=1


# Install and configure redis
RUN apt-get update
RUN apt-get install -y redis-server
COPY deploy/redis.conf /etc/redis.conf

ENV APP_DIR=/flask-celery-example
RUN mkdir -p ${APP_DIR}
WORKDIR ${APP_DIR}

COPY requirements.txt ./  
RUN pip install --no-cache-dir -r requirements.txt  
RUN pip install --no-cache-dir gunicorn
# RUN rm requirements.txt 

COPY . ${APP_DIR}

# Install supervisor and add services
RUN apt-get install -y supervisor nano
RUN mkdir -p /var/log/supervisord/
COPY deploy/supervisor/*.conf /etc/supervisor/conf.d/
RUN ls -la  /etc/supervisor/conf.d/

RUN mkdir -p /var/log/celery/

# RUN systemctl enable supervisor
# RUN service supervisor start
# RUN supervisorctl status all

RUN /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
# ENTRYPOINT ["supervisord", "-c", "supervisord.conf"]
ENTRYPOINT [ "/bin/bash" ]