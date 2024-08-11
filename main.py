import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import interp1d

pe_data = pd.read_csv('PE.csv')
ne_data = pd.read_csv('NE.csv')
data2 = pd.read_csv('Extracted_data-final.csv')

NE_SOC = ne_data.iloc[:, 0].values
NE_OCV = ne_data.iloc[:, 1].values

PE_SOC = pe_data.iloc[:, 0].values
PE_OCV = pe_data.iloc[:, 1].values

FC_Cap = data2.iloc[:, 4].values
FC_OCV = data2.iloc[:, 5].values

PE_SOC_new = np.linspace(min(PE_SOC), max(PE_SOC), 100)
NE_SOC_new = np.linspace(min(NE_SOC), max(NE_SOC), 100)

PE_OCV_new = np.interp(PE_SOC_new, PE_SOC, PE_OCV)
NE_OCV_new = np.interp(NE_SOC_new, NE_SOC, NE_OCV)

Up = np.column_stack((PE_SOC_new, PE_OCV_new))
Un = np.column_stack((NE_SOC_new, NE_OCV_new))

interpolate_un = interp1d(Un[:, 0], Un[:, 1], kind='linear', fill_value='extrapolate')
Un_interp_y = interpolate_un(Up[:, 0])

y_diff = Up[:, 1] - Un_interp_y

FC_Cap_new = np.linspace(min(FC_Cap), max(FC_Cap), 100)

FC_OCV_new = np.interp(FC_Cap_new, FC_Cap, FC_OCV)

plt.plot(Up[:, 0], Up[:, 1], '-', label='PE')
plt.plot(Un[:, 0], Un[:, 1], '-', label='NE')
plt.plot(Up[:, 0], y_diff, '-', label='Difference (PE - NE)')
plt.plot(FC_Cap_new + 0.6, FC_OCV_new, '-', label='FC')

plt.xlabel('SOC')
plt.ylabel('OCV')
plt.legend()


plt.show()
