## Battery Voltage Simulation and Optimization

This project analyzes and optimizes a battery model to simulate voltage based on charge and voltage profiles for positive and negative electrodes.

### Dependencies
- `pandas`
- `numpy`
- `scipy`
- `matplotlib`

### Files
- `Electrode-Updated.csv`: Electrode data (not used directly).
- `Extracted_data-final.csv`: Battery capacity and open-circuit voltage data.
- `PE.csv`: Positive electrode data (SOC and OCV).
- `NE.csv`: Negative electrode data (SOC and OCV).

### Running the Script
1. Ensure required CSV files are in the same directory as the `main.ipynb` script.
2. Run the script using Python.

### Results
- Outputs optimized parameters and RMSE.
- Generates plots comparing actual and simulated voltages.
