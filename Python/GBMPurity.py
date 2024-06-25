import pandas as pd

def pyLoadData(name, path):
    # Get the file extension
    ext = name.split('.')[-1]
    
    # Switch-like structure to read the file based on its extension
    if ext == 'csv':
        data = pd.read_csv(path)
    elif ext == 'tsv':
        data = pd.read_csv(path, sep='\t')
    elif ext == 'xlsx':
        data = pd.read_excel(path, engine='openpyxl')
    else:
        raise ValueError("Invalid file; Please upload a .csv, .tsv, or .xlsx file")
    
    return data
