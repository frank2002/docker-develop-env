FROM python:3.11.5-bookworm as builder-image

ARG SSH_PASSWORD
ARG SSH_PUBLIC_KEY

COPY requirements.txt .
RUN pip install --default-timeout=1000 --no-cache-dir -r requirements.txt

WORKDIR ./app

COPY . .

RUN apt-get update -y \
    && apt-get install -y libaio1 vim nano openssh-server locales

# Ensure proper permissions for SSH files

RUN echo "root:${SSH_PASSWORD}" | chpasswd

RUN echo "${SSH_PUBLIC_KEY}" >> /root/.ssh/authorized_keys

RUN chmod 600 /root/.ssh/authorized_keys && chmod 700 /root/.ssh


# Uncomment the desired locale and generate it
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

# Set environment variables for the locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

EXPOSE 8088 22

CMD service ssh restart && tail -f > /dev/null
