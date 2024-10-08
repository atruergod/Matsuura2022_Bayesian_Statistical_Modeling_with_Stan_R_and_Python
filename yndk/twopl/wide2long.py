import sys 
import os 
import pandas as pd
import numpy as np


def wide2long(filename):
    df = pd.read_csv(filename)
    print(df.head())

    item_names = list(df.keys())
    item_names.remove("ID")
    item_names.remove("name")

    long = []
    for iid, iname in enumerate(item_names):
        for pid in range(len(df)):
            if np.isnan(df[iname][pid]) == False:
                #      st.id,                name,     person.id,  item.id,      response
                dd = [ str(df.ID[pid]),  df.name[pid],   pid + 1,  iid + 1,  int(df[iname][pid]) ]
                
                long.append(dd)
    #
    long = pd.DataFrame(long, columns=["st.id", "name", "person.id", "item.id", "response"])

    path, fname = os.path.split(filename)

    longfilename = os.path.join(path, "long_" + fname)
    print("output: ", longfilename)
    long.to_csv(longfilename)




if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]}  file_wide_form.csv")
        print(f"output will be long_file_wide_form.csv")
        quit()
    print(sys.argv[0], sys.argv[1])
    wide2long(sys.argv[1])
#