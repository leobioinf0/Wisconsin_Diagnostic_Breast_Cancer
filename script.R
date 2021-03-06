## ----setup, include=FALSE--------------------------------------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ----libraries, message=FALSE----------------------------------------------------------------------------------------------------------------------------
library(dplyr)
library(ggplot2)
library(DescTools)
library(lmtest)


## ----read.table------------------------------------------------------------------------------------------------------------------------------------------
WDBC <- read.table(file.path("./WDBC.dat"), header=TRUE, sep = "\t")


## ----drop.columns----------------------------------------------------------------------------------------------------------------------------------------
WDBC <- WDBC[, -grep("id|_se|_worst", colnames(WDBC))]

## ----edit.colnames---------------------------------------------------------------------------------------------------------------------------------------
colnames(WDBC) <- gsub('_mean', '', colnames(WDBC), fixed=TRUE)

## ----edit.diag-------------------------------------------------------------------------------------------------------------------------------------------
WDBC$diagnosis <- as.factor(recode(WDBC$diagnosis, B = "Benigno", M = "Maligno"))


## ----summary.WDBC----------------------------------------------------------------------------------------------------------------------------------------
summary(WDBC)


## ----count.diag------------------------------------------------------------------------------------------------------------------------------------------
count.diag <- count(WDBC, diagnosis)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
pie<- ggplot(count.diag, aes(x="", y=n, fill=diagnosis)) + 
  geom_bar(width = 1, stat = "identity") + 
  coord_polar("y", start=0) +
  geom_text(aes(y = n/2 + c(cumsum(n)[-length(n)], 0), 
            label = n), size=5) +
  ggtitle("Proporción en diagnóstico")



## ----seed------------------------------------------------------------------------------------------------------------------------------------------------
set.seed(1832)


## --------------------------------------------------------------------------------------------------------------------------------------------------------

df <- WDBC %>% 
  group_by(diagnosis) %>%
  slice_sample(n = 50, replace = FALSE)


## ----count.diag.50---------------------------------------------------------------------------------------------------------------------------------------
df %>% count(diagnosis)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
Desc(df)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
quant.03area = quantile(df$area,0.333)
print(quant.03area)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
quant.06area = quantile(df$area,0.666)
print(quant.06area)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
df[,"area.categorica"] = cut(df$area, breaks = c(min(df$area), quant.03area, quant.06area, max(df$area)),
    labels = c("Pequeña", "Media", "Grande"),
    include.lowest = TRUE)

df$area.categorica <- as.factor(df$area.categorica)

table(df$area.categorica)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
df[,"textura.categorica"] = cut(df$texture, 
                     breaks = c(min(df$texture), mean(df$texture), max(df$texture)), 
                     labels = c("Claro", "Oscuro"),
                     include.lowest = TRUE)

df$textura.categorica <- as.factor(df$textura.categorica)

table(df$textura.categorica)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
shapiro.test(df$texture)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
IC=t.test(df$texture, conf.level = 0.95)
IC$conf.int


## --------------------------------------------------------------------------------------------------------------------------------------------------------
shapiro.test(df$perimeter)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
limite_sup= IC$conf.int[2]
t.test(df$texture, alternative='two.sided',
       conf.level=0.9, mu=limite_sup)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
bartlett.test(df$texture~df$area.categorica)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
bartlett.test(df$texture~df$diagnosis)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
t.test(df$texture~df$diagnosis)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
table(df$diagnosis,df$area.categorica)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
chisq.test(table(df$diagnosis,df$textura.categorica))


## --------------------------------------------------------------------------------------------------------------------------------------------------------
chisq.test(table(df$diagnosis,df$area.categorica))


## --------------------------------------------------------------------------------------------------------------------------------------------------------
diag_tex_tb <- table(df$textura.categorica,df$diagnosis)


## ----OddsRatio-------------------------------------------------------------------------------------------------------------------------------------------
res <- OddsRatio(diag_tex_tb, conf.level=0.95)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
boxplot(df$texture ~ df$area.categorica)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
aov1 <-aov(df$texture ~ df$area.categorica)
summary(aov1)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
TukeyHSD(aov1)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
model0 <- lm(formula =  area ~ texture, data = df)
summary(model0)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
shapiro.test(model0$residuals)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
model0.stdres <- rstandard(model0) 
qqnorm(model0.stdres,  ylab="Standardized Residuals", xlab="Normal Scores") 
qqline(model0.stdres)

## --------------------------------------------------------------------------------------------------------------------------------------------------------
bptest(model0)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
dwtest(model0)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
plot(model0)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
model1 <- lm(formula =  area ~ I(texture^2), data = df)
model2 <- lm(formula =  area ~ log(texture), data = df)
model3 <- lm(formula =  area ~ I(texture^(-1)), data = df)
model_cuadratico <- lm(formula =  area ~ poly(texture, 1), data = df)
model_cuadratico2 <- lm(formula =  area ~ poly(texture, 2), data = df)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
 anova(model0, model1)

## --------------------------------------------------------------------------------------------------------------------------------------------------------
 anova(model0, model3)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
anova(model0, model_cuadratico)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
anova(model0, model_cuadratico2)


## --------------------------------------------------------------------------------------------------------------------------------------------------------
cbind(model0=AIC(model0), model1=AIC(model1), model2=AIC(model2), model3=AIC(model3), model_cuadratico=AIC(model_cuadratico), model_cuadratico2=AIC(model_cuadratico2))


## --------------------------------------------------------------------------------------------------------------------------------------------------------
df$diagnosis.fac <- c(rep(0,50),rep(1,50))


## --------------------------------------------------------------------------------------------------------------------------------------------------------
model.m <- lm(formula =  diagnosis.fac ~ I(perimeter^2) + radius + texture  + concavity + area, data = df)
summary(model.m)

