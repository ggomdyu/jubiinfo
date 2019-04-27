import urllib
import tkinter
from flask import Flask
from flask_restful import Resource, Api, request
import pymysql
import enum
import datetime
import uuid

class StatusCode(enum.Enum):
    def __str__(self):
       return str(self.value)

    SUCCESS = 200
    FAILURE = 400
    ALREADY_EXIST = 201
    NOT_FOUND = 202

class GetCompetitions(Resource):
    def get(self):
        sql_cursor.execute("SELECT * FROM competitionList ORDER BY endDate;")
        rows = sql_cursor.fetchall()

        competitions = []
        for row in rows:
            music_count: int = row[2]

            competition = {
                "name": row[0],
                "endDate": row[1],
                "musicCount": music_count
            }
            for i in range(music_count):
                competition[f"music{i + 1}Id"] = row[3 + i]
                competition[f"music{i + 1}Id"] = row[4 + i]

            competitions.append(competition)

        return {
            "status": StatusCode.SUCCESS.__str__(),
            "list": competitions
        }

class CreateCompetition(Resource):
    def post(self):
        name = request.args.get("name", default="", type=str)

        sql_cursor.execute(f"SELECT name FROM competitionList WHERE(name=\"{name}\");");

        if len(sql_cursor.fetchall()) <= 0:
            end_date = request.args.get("endDate", default="", type=int)

            music_count = request.args.get("musicCount", default="", type=int)
            music_list = ([0, 0], [0, 0], [0, 0], [0, 0], [0, 0])
            for i in range(music_count):
                music_list[i][0] = request.args.get(f"music{i + 1}Id", default="", type=str)
                music_list[i][1] = request.args.get(f"music{i + 1}Difficulty", default="", type=str)

            sql_cursor.execute(f"INSERT INTO competitionList VALUES(\"{name}\", \"{end_date}\", {music_count}, {music_list[0][0]}, {music_list[0][1]}, {music_list[1][0]}, {music_list[1][1]}, {music_list[2][0]}, {music_list[2][1]}, {music_list[3][0]}, {music_list[3][1]}, {music_list[4][0]}, {music_list[4][1]});")
            sql_connection.commit()

            return {"status": StatusCode.SUCCESS.__str__()}
        else:
            return {"status": StatusCode.ALREADY_EXIST.__str__()}

class DeleteCompetitions(Resource):
    def delete(self):
        name = request.args.get("name", default="", type=str)

        if sql_cursor.execute(f"DELETE FROM competitionList WHERE name=\"{name}\"") > 0:
            return {"status": StatusCode.SUCCESS.__str__()}
        else:
            return {"status": StatusCode.NOT_FOUND.__str__()}

if __name__ == "__main__":
    # Connect to MySQL
    sql_connection = pymysql.connect(host="127.0.0.1", user="root", password="", db="Competition",
                                     charset="utf8")
    sql_cursor = sql_connection.cursor()
    sql_cursor.execute("USE Competition;")

    # Create flask instance
    flask_app = Flask(__name__)
    flask_api = Api(flask_app)

    flask_api.add_resource(GetCompetitions, '/competition')
    flask_api.add_resource(CreateCompetition, '/competition')
    flask_api.add_resource(DeleteCompetitions, '/competition')

    flask_app.run(host="127.0.0.1", port=8888)
