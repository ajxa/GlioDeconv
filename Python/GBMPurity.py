import pandas as pd
import numpy as np
import torch

import sys
sys.path.insert(1, 'Python')

def pyLoadData(ext, path):
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



def GBMPurity(data):
    
    data.set_index(data.columns[0], inplace=True)
    
    # Import features used for model
    gene_lengths = pd.read_csv("data/GBMPurity_genes.csv")
    genes = gene_lengths['feature_name']
    lengths = gene_lengths['feature_length'].values
    
    # Import model
    model = torch.load("Python/model/GBMPurity.pt")
    model.eval()


    # Order data for input to model
    X = data.T
    X = X.reindex(columns=genes, fill_value=0)
    X = np.log2(tpm(X.values, lengths) + 1)
    
    # Input to GBMPurity
    y_pred = model(torch.tensor(X).float()).detach().numpy().flatten().clip(0, 1)
    
    # Create results table
    samples = data.columns
    results = pd.DataFrame({'Sample':samples, 'Purity':y_pred})
    
    return results

