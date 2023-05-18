# Predict Housing Prices in Ames
### Objective
The goal of this project was to build two models that can predict the price of a house (in log scale) using data on houses sold in Ames. One model will be based on a tree method while the other will be based on a linear regression method. The Ames housing dataset contains the sales price along with other characteristics of individual residential properties sold in Ames, IA from 2006 to 2010. The Ames_data.csv file has 2930 rows and 83 columns. The testIDs.dat file contains 879 rows and 10 columns, and it was used to generate 10 sets of training/test splits from Ames_data.csv. Ultimately, gradient boosting and elastic net regularization were used for the tree and linear models, respectively.
### Pre-Processing
Before any models could be built, the data had to be cleaned and processed. Categorical variables were converted to binary dummy variables. I searched for missing values in the data and found that there were only 159 of them, all from “Garage_Yr_Blt”. Further investigation revealed that those 159 houses corresponded exactly to the "No_Garage" category under the column “Garage_Cond”. Another categorical feature “Garage_Type” showed that 157 of those houses did not have garages while two had detached garages. Thus, it seemed that the 159 houses had missing values in “Garage_Yr_Blt” because no garage was ever built for them. To handle this, all NA values were replaced with zero.

For the linear model, additional pre-processing was performed on the training data. 11 features were removed. They were “Street”, “Utilities”, “Condition_2”, “Roof_Matl”, “Heating”, “Pool_QC”, “Misc_Feature”, “Low_Qual_Fin_SF”, “Pool_Area”, “Longitude”, and “Latitude”. These variables were removed either because they were imbalanced (most samples belonged to one category) or not very interpretable. Additionally, certain numerical variables were winsorized using the upper 95% quantile as the cut off. These variables were "Lot_Frontage", "Lot_Area", "Mas_Vnr_Area", "BsmtFin_SF_2", "Bsmt_Unf_SF", "Total_Bsmt_SF", "Second_Flr_SF", 'First_Flr_SF', "Gr_Liv_Area", "Garage_Area", "Wood_Deck_SF", "Open_Porch_SF", "Enclosed_Porch", "Three_season_porch", "Screen_Porch", and "Misc_Val". Note that these steps were performed before converting the categorical variables to dummy variables.
### Results
The models were trained and evaluated on all 10 splits of the data generated at the beginning. Predicted prices generated from each model for the test data were saved in their respective split folders. Gradient boosting took noticeably more time to fit than elastic net regularization. The root-mean-square errors between both models' predicted prices and the actual observed prices were well under 0.135 for all 10 test splits. Specific RMSE values for each split are provided in the table below.
| Split # | Tree RMSE | Linear RMSE |
|---------|-----------| ------------|
| 1       | 0.1127    | 0.1227      |
| 2       | 0.1149    | 0.1196      |
| 3       | 0.1149    | 0.1212      |
| 4       | 0.1115    | 0.1204      |
| 5       | 0.1101    | 0.1121      |
| 6       | 0.1280    | 0.1330      |
| 7       | 0.1299    | 0.1259      |
| 8       | 0.1272    | 0.1206      |
| 9       | 0.1320    | 0.1300      |
| 10      | 0.1213    | 0.1238      |