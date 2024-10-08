library(openxlsx)
library(gtsummary)
library(tidyverse)
working_directory <- 'C:/Users/zhu-s/OneDrive/Graduate File/Course/Bios6624/BIOS6624-shuai/Project1'

df_cleaned <- read.xlsx(paste0(working_directory, '/DataProcessed/cleaned data.xlsx'))
df_hiv_lm_model <- df_cleaned

outcome <- c('VLOAD_year2_log', 'LEU3N_year2', 'AGG_PHYS_year2', 'AGG_MENT_year2')
predictors <- c('Hard_drugs', 'BMI', 'Age', 'Edu', 'Adh')
baseline_outcome <- c('VLOAD_year0_log', 'LEU3N_year0', 'AGG_PHYS_year0','AGG_MENT_year0')

## univarite model

df_hiv_lm_model%>%tbl_uvregression(
  method = lm,
  y = VLOAD_year2_log,
  include = c('Hard_drugs', 'BMI', 'Age', 'Edu', 'VLOAD_year0_log', 'Adh')
)%>%modify_header(label = "**VLOAD Model**")

df_hiv_lm_model%>%tbl_uvregression(
  method = lm,
  y = LEU3N_year2,
  include = c('Hard_drugs', 'BMI', 'Age', 'Edu', 'LEU3N_year0', 'Adh')
)%>%modify_header(label = "**LEU3N Model**")

df_hiv_lm_model%>%tbl_uvregression(
  method = lm,
  y = AGG_PHYS_year2,
  include = c('Hard_drugs', 'BMI', 'Age', 'Edu', 'AGG_PHYS_year0', 'Adh')
)%>%modify_header(label = "**AGG_PHYS Model**")

df_hiv_lm_model%>%tbl_uvregression(
  method = lm,
  y = AGG_MENT_year2,
  include = c('Hard_drugs', 'BMI', 'Age', 'Edu', 'AGG_MENT_year0', 'Adh')
)%>%modify_header(label = "**AGG_MENTModel**")

## multiple variable regression fit

model_list = list()
for (i in 1:4){
  model.fit <- lm(paste0(outcome[i],'~', paste0(predictors, collapse ='+'),'+',baseline_outcome[i] ),
                 data = df_hiv_lm_model)
  model_list[[i]] <- model.fit
}

save_diagnostic <- function(model, filename){
  jpeg(paste0(working_directory, '/Figure/',filename),width = 800, height = 800,res = 100)
  par(mfrow = c(2, 2)) 
  plot(model)
  dev.off()
}

summary(model_list[[1]])
save_diagnostic(model_list[[1]], 'diagnosis model1.jpg')
summary(model_list[[2]])
save_diagnostic(model_list[[2]], 'diagnosis model2.jpg')
summary(model_list[[3]])
save_diagnostic(model_list[[3]], 'diagnosis model3.jpg')
summary(model_list[[4]])
save_diagnostic(model_list[[4]], 'diagnosis model4.jpg')


df_ci <- rbind(confint(model_list[[1]])[2,], confint(model_list[[2]])[2,], confint(model_list[[3]])[2,], confint(model_list[[4]])[2,])%>%as_tibble()%>%
  mutate_if(is.numeric, round, digits = 3)%>%data.frame()

df_estimate <- data.frame(Estimate= c(coef(model_list[[1]])[2], coef(model_list[[2]])[2], coef(model_list[[3]])[2], coef(model_list[[4]])[2]), 
           '2.5%' =df_ci[,1] , '97.5.5%' = df_ci[,2])
colnames(df_estimate) <- c('Estimate', '2.5%', '97.5%')
rownames(df_estimate) <- c('Log-transformed Viral Load', 'CD4+ T Cell Count at Year 2', 
                           "Physical Quality of Life at Year 2", "Mental Quality of Life at Year 2")
df_estimate%>%
  saveRDS(paste0(working_directory, '/DataProcessed/lm estimate.RDS'))



