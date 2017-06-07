FROM python:3.6-slim

WORKDIR /app
CMD ["bin/build-docs.sh"]

COPY ./requirements.txt .
RUN pip install -r requirements.txt
