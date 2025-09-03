import pandas as pd
import numpy as np


df=pd.read_csv('dataa.csv')


df.columns = df.columns.str.lower()


df.to_csv('dataa.csv', index=False)


#UNION TWO CSV

df2 = pd.read_csv('turkiye_yol_koordinatlari.csv')
df2.columns = df2.columns.str.lower()
df = pd.concat([df, df2], ignore_index=True)
df.to_csv('final_data.csv', index=False)




def turkish_char_normalize(s):
    replace_map = str.maketrans("çğıöşüÇĞİÖŞÜ", "cgiosuCGIOSU")
    return s.translate(replace_map).upper().strip()

df["city"] = df["city"].apply(turkish_char_normalize)

df.to_csv('final_data.csv', index=False)


df = df.sort_values(by = "city")
df.to_csv('final_data.csv', index=False)
