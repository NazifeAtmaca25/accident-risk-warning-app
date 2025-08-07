import pandas as pd
import numpy as np


df=pd.read_csv('risk_data.csv')
df["city"] = df["description"].apply(lambda x: x.split()[0])
df["district"] = df["description"].apply(lambda x: x.split()[1])

df["description"] = df["description"].apply(lambda x: " ".join(x.split()[2:]))

df["description"] = df["description"].apply(lambda x: x.replace("  ", " "))
df["description"]= df["description"].apply(lambda x: x.strip())
df["description"] = df["description"].apply(lambda x: x.split(" - ")[-1])
df["description"] = df["description"].str.replace("-","")

# TUNING DURATION FROM DESCRIPTION

df[["duration", "number_of_accidents"]] = df["description"].str.extract(r"Son (\d+) ayda (\d+) kaza")
df["duration"] = df["description"].str.extract(r"Son (\d+ ayda)")


df["duration"] = df["duration"].apply(lambda x: x.replace(" ayda", " months"))
df["duration"] = df["duration"].apply(lambda x: x.replace(" yılda", " year"))

print(df.head())


#SAVE TO CSV
df.to_csv('all_data.csv', index=False)