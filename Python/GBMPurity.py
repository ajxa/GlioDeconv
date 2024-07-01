import pandas as pd
import numpy as np
import torch
import matplotlib.pyplot as plt 
import seaborn as sns

import sys
sys.path.insert(1, 'Python')



def pyLoadData(ext, path):
    try:
        # Switch-like structure to read the file based on its extension
        if ext == 'csv':
            data = pd.read_csv(path)
        elif ext == 'tsv':
            data = pd.read_csv(path, sep='\t')
        elif ext == 'xlsx':
            data = pd.read_excel(path, engine='openpyxl')
        else:
            raise ValueError("Invalid file; Please upload a .csv, .tsv, or .xlsx file")
    except Exception as e:
        raise ValueError(f"Failed to read the file: {e}")
    return data



def tpm(X: np.ndarray, lengths: np.ndarray):
    """
    Calculate TPM (Transcripts Per Million) normalization for RNA-seq data.

    Parameters:
    X (np.ndarray): 2D array of raw read counts (sample x genes).
    lengths (np.ndarray): 1D array of feature lengths (e.g., gene lengths).

    Returns:
    np.ndarray: TPM normalized values.
    """
    
    if X.shape[1] != lengths.shape[0]:
        raise ValueError("The number of rows in X must match the length of lengths")
    
    # Calculate RPK (Reads Per Kilobase)
    rpk = np.divide(X, lengths)
    
    # Calculate the scaling factor
    scaling_factor = np.nansum(rpk, axis=1).reshape(-1, 1)
    
    # Calculate TPM
    tpm = (rpk / scaling_factor) * 1e4
    
    return tpm



def pyCheckData(df):
    
    errors = []
    warnings = []
    
    # Import required genes
    gene_lengths = pd.read_csv("data/GBMPurity_genes.csv")
    genes = gene_lengths['feature_name']
    
    # Check Dimensions
    if df.shape[0] < 1:
        errors.append("We didn't detect any genes.")
        return errors, warnings, None
        
    if df.shape[1] <= 1:
        errors.append("We didn't detect any samples.")
        return errors, warnings, None
    
    # Missing values
    if df.isnull().values.any():
        warnings.append(f"We found {df.isnull().values.sum()} missing value(s). These will be converted to 0.")
        df = df.fillna(0)
    
    # Check for duplicate genes
    input_genes = df.iloc[:,0]
    duplicate_genes = input_genes[input_genes.duplicated()].unique()
    if len(duplicate_genes) > 0:
        warnings.append(f'We found {len(duplicate_genes)} duplicate gene(s). Counts for these genes will be summed for each sample.')
    
    data = df.set_index(df.columns[0])
    data = data.groupby(data.index).sum()
    
    # Check appropriate genes
    overlap = set(input_genes).intersection(set(genes)) 
    if len(overlap) == 0:
        errors.append("We didn't find any required genes. Are the provided genes in the HGNC format e.g. CD47?")
        return errors, warnings, None
    else:
        p_overlap = len(overlap)/len(genes)
        if p_overlap < 0.8:
            errors.append(f"We found {int(p_overlap * 100)}% of the required genes. Purity estimates will be unreliable under 80%.")
            return errors, warnings, None
        elif p_overlap < 0.99:
            warnings.append(f"We found {int(p_overlap * 100)}% of the required genes. Note that GBMPurity tends to underestimate the tumour purity with more missing genes.")
    

    # Check correct data
    # Non-numeric
    non_numeric = data.apply(lambda s: pd.to_numeric(s, errors='coerce').notnull().all()).all()
    if not non_numeric:
        errors.append("All gene expression values must be numeric.")
        return errors, warnings, None

    # Negative values
    if (data.values < 0).any():
        errors.append("Gene expression values must be non-negative. Data should be uploaded as raw counts (without batch correction).")
        return errors, warnings, None
    
    # Process data to return
    data = data.T
    data = data.reindex(columns=genes, fill_value=0)

    return errors, warnings, data




def GBMPurity(data):
    
    # Import gene lengths
    gene_lengths = pd.read_csv("data/GBMPurity_genes.csv")
    lengths = gene_lengths['feature_length'].values

    # Transform input data
    X = np.log2(tpm(data.values, lengths) + 1)
    
    # Import model
    model = torch.load("Python/model/GBMPurity.pt")
    model.eval()
    
    # Input to GBMPurity
    y_pred = model(torch.tensor(X).float()).detach().numpy().flatten().clip(0, 1)
    
    samples = data.index.values
    results = pd.DataFrame({'Sample':samples, 'Purity':y_pred})
    return results
