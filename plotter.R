# R plots

{
library(tidyverse)
library(ggplot2)
library(gtsummary)
library(scales)
library(webshot2)

df <- read.delim("data/fake_data.tsv") %>% 
  select(-RowID, -First_name, -Last_name, -Email) %>%
  mutate( Date=as.Date(Date), Month=factor(Month, levels=month.name) )
}

# Costs -------------------------------------------------------------------

monthly <- df %>% group_by(Month) %>%
  summarise(
    Total = sum(Cost, na.rm=TRUE),
    Revenue = sum(Cost * Quantity, na.rm=TRUE),
    .groups="drop"
  ) %>%
  mutate(Cumulative_Revenue = cumsum(Revenue))

ggplot(monthly, aes(x=Month, group=1)) +
  geom_line(aes(y=Total, color="Total Cost"), linewidth=1) +
  geom_line(aes(y=Revenue, color="Revenue"), linewidth=1) +
  geom_point(aes(y=Total, color="Total Cost")) +
  geom_point(aes(y=Revenue, color="Revenue")) +
  
  geom_smooth(aes(y=Total, color="Total Cost"), method="loess",
              se=FALSE, linewidth=1, linetype="dashed") +
  geom_smooth(aes(y=Revenue, color="Revenue"), method="loess",
              se=FALSE, linewidth=1, linetype="dashed") +
  
  scale_color_manual(values = c("Total Cost"="#BEBADA", "Revenue"="#FDB462")) +
  labs(x=" ", y=" ", color="Metric",
       title="Monthly costs and revenue") +
  theme_minimal() + theme(legend.position="bottom")

ggsave("plots/costs_line.png", width=4100,height=2350,units="px")
rm(monthly)

# Categories --------------------------------------------------------------

df %>% select( Category, PurchasedVia, OnSale, Month, Colour, Stars ) %>% 
  tbl_summary( by=Category,
               statistic=list( all_continuous() ~ "{mean} ({sd})",
                               all_categorical() ~ "{n} ({p}%)" ), # {n} / {N}
               digits=all_continuous() ~ 2,
               label=list(AgeGroup="Age", OnSale="Sale Item"),
               missing_text="(Missing)"
               ) %>%
  add_overall() %>%
  bold_labels() %>% modify_header(label ~ "**Variable**") %>% 
  add_p(
    test = all_categorical() ~ "fisher.test",
    test.args = all_tests("fisher.test") ~ list( simulate.p.value = TRUE, B = 10000 )
  ) %>%
  modify_caption("**Summary of some variables that may contribute to purchases across categories**") %>%
  as_gt() %>% gt::tab_source_note(gt::md("*This data is simulated.*")) %>% gt::gtsave("plots/category.png")

###

# df %>% count(Category, OnSale) %>% group_by(Category) %>%
#   mutate(prop = n / sum(n)) %>%
#   ggplot(aes(x=Category, y=prop, fill=OnSale)) +
#   geom_col() + scale_y_continuous(labels=percent_format()) +
#   labs(x="Category", y="Percentage", fill="On Sale",
#        title = "Purchases stacked if item was on sale or not") +
#   theme_minimal() #+ facet_wrap(~ OnSale)

# df %>% count(Month, Category) %>% group_by(Month) %>%
#   mutate(prop = n / sum(n)) %>%
#   ggplot(aes(x=Month, y=Category, fill=prop)) +
#   geom_tile(colour="white") + 
#   scale_fill_viridis_c(labels=scales::percent_format()) + # scale_fill_gradient2(
#   geom_text(aes(label = scales::percent(prop, accuracy=0.1)),
#             colour="black", size=3) +
#   labs(x="Month", y="Category", fill="Percentage",
#     title="Heatmap of monthly purchases") +
#   theme_minimal() + theme(legend.position="none") +
#   theme(axis.text.x = element_text(angle=45, hjust=1)) 

df %>% count(Month, Category, OnSale) %>% group_by(Month, OnSale) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(aes(x=Month, y=Category, fill=prop)) +
  geom_tile(colour="white") +
  scale_fill_gradient2(labels=scales::percent_format()) +
  geom_text(aes(label = scales::percent(prop, accuracy=0.1)),
    colour="black", size=3) +
  labs(x=" ", y=" ", fill="Percentage",
       title="Heatmap of monthly purchases by sale status") +
  theme_minimal() + theme(legend.position="none") +
  theme(axis.text.x = element_text(angle=45, hjust=1)) +
  facet_wrap(~ OnSale, ncol=1)
ggsave("plots/category_heatmap.png")

# Stars -------------------------------------------------------------------

df %>% select( Stars, AgeGroup, Gender, Category, Quantity, City ) %>% 
  tbl_summary( by=Stars,
               statistic=list( all_continuous() ~ "{mean} ({sd})",
                               all_categorical() ~ "{n} ({p}%)" ), # {n} / {N}
               digits=all_continuous() ~ 2,
               label=list(AgeGroup="Age", OnSale="Sale Item"),
               missing_text="(Missing)"
  ) %>%
  add_overall() %>%
  bold_labels() %>% modify_header(label ~ "**Variable**") %>% 
  add_p(
    test = all_categorical() ~ "fisher.test",
    test.args = all_tests("fisher.test") ~ list( simulate.p.value = TRUE, B = 10000 )
  ) %>%
  modify_caption("**Summary of some variables that may contribute to higher ratings**") %>%
  as_gt() %>% gt::tab_source_note(gt::md("*This data is simulated.*")) %>% gt::gtsave("plots/stars.png")

###

ggplot(df, aes(x=AgeGroup, y=Stars, fill=AgeGroup)) +
  geom_violin(alpha=0.5, trim=FALSE) +
  scale_fill_brewer(palette="Set3") +
  labs(x=" ", y=" ",
       title="Star ratings by age groups") +
  theme_minimal() + theme(legend.position="none")
ggsave("plots/stars_violin.png")

ggplot(df, aes(x=AgeGroup, fill=factor(Stars))) +
  geom_bar(position="fill") +
  scale_y_continuous(labels=scales::percent) +
  scale_fill_brewer(palette="Set3", direction=1) + 
  labs(x=" ", y=" ", fill="Stars",
       title="Distribution of ratings by age groups") +
  theme_minimal() + theme(legend.position="bottom")
ggsave("plots/stars_bar.png", width=4100,height=2350,units="px")

# ggplot(df, aes(x=Quantity, y=Stars)) +
#   geom_jitter(width=0.15, height=0.1, alpha=0.3, colour="#4C78A8") +
#   geom_smooth(method="lm", se=TRUE, colour="#E45756") +
#   labs(x=" ", y=" ",
#        title="Relationship between rating and purchase quantity") +
#   theme_minimal()

df %>% count(Quantity, Stars) %>% group_by(Quantity) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(aes(x=Quantity, y=Stars, fill=prop)) +
  geom_tile(colour="white") +
  scale_fill_gradient2(labels=scales::percent_format()) +
  geom_text(aes(label = scales::percent(prop, accuracy=0.1)),
            colour="black", size=3) +
  labs(x="Quantity", y="Stars", fill="Percentage",
    title="Heatmap of ratings and purchase quantity") +
  theme_minimal() + theme(legend.position="none")
ggsave("plots/stars_heatmap.png")

# End
