import oracledb as oracledb
import pandas as pd

dsn = "213.184.8.44:1521/orcl"
connection = oracledb.connect(user="wendan", password="wednav", dsn=dsn)


def load_csv_to_table(csv_file, table_name, column_mapping):

    try:
        data = pd.read_csv(csv_file, sep=";")

        cursor = connection.cursor()

        columns = ", ".join(column_mapping)
        placeholders = ", ".join([f":{i + 1}" for i in range(len(column_mapping))])
        sql = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"

        for _, row in data.iterrows():
            cursor.execute(sql, tuple(row[column] for column in column_mapping))

        connection.commit()
        print(f"Dane z pliku {csv_file} zostały załadowane do tabeli {table_name}.")

    except Exception as e:
        print(f"Wystąpił błąd podczas ładowania danych: {e}")

    finally:
        cursor.close()


if __name__ == "__main__":
    load_csv_to_table(
        csv_file="uzytkownicy.csv",
        table_name="Uzytkownicy",
        column_mapping=["imie", "nazwisko", "email", "nr_telefonu"]
    )

    load_csv_to_table(
        csv_file="gry.csv",
        table_name="Gry",
        column_mapping=["tytul", "gatunek", "wydawca", "liczba_graczy", "czas_rozgrywki", "status"]
    )

connection.close()
