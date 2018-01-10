set.seed(60)
x <- runif(10, 0.2, 0.8)
y <- rnorm(10, mean = 1.5*x, sd = 0.7)

dat <- data.frame(x=x,y=y)
dat$z <- c(0, 1, 1, 0, 1, 0, 0, 1, 0, 1)
dat

theme_sim <- function () {
  theme(axis.title = element_blank(),
        axis.text = element_blank(),
        #axis.line = element_blank(),
        axis.line = element_line(size = 1),
        axis.ticks = element_blank(),
        #axis.ticks = element_line(size = 2.2, color = 'black'),
        #axis.ticks.length=unit(8, "pt"),
        panel.background = element_blank(),
        legend.position = 'none')
}

library(ggplot2)
fp <- ggplot(dat, aes(x=x,y=y)) + 
  geom_point(size = 4) + 
  scale_x_continuous(breaks = c(0.4, 0.6), limits = c(0.2, 0.8),
                     expand = c(0, 0)) +
  scale_y_continuous(limits = c(-0.5, 2.5),
                     breaks = c(0.3, 1.1, 1.9),
                     expand = c(0, 0)) + 
  theme_sim()

rp <- ggplot(dat, aes(x=x,y=y,color=factor(z))) + 
  geom_point(size = 4) + 
  scale_color_manual(values = c('#67a9cf', '#ef8a62')) +
  scale_x_continuous(breaks = c(0.4, 0.6), limits = c(0.2, 0.8),
                     expand = c(0, 0)) +
  scale_y_continuous(limits = c(-0.5, 2.5),
                     breaks = c(0.3, 1.1, 1.9),
                     expand = c(0, 0)) + 
  theme_sim()

library(dplyr)
m_dat <- dat %>%
  group_by(z) %>%
  summarise(m_y = mean(y),
            se_y = sd(y)/sqrt(n()),
            ci_low = m_y - 1.9*se_y,
            ci_high = m_y + 1.9*se_y)
m_dat$x <- c(0.4, 0.6)

m_dat
ep <- ggplot(dat, aes(x=x,y=y,color=factor(z))) + 
  geom_point(size = 4, alpha = 0.2) + 
  scale_color_manual(values = c('#67a9cf', '#ef8a62')) +
  geom_point(aes(x=x, y=m_y,color=factor(z)),
             m_dat,
             size = 15,
             shape = 45) +
  geom_errorbar(aes(x=x, y=m_y, ymin = ci_low, ymax = ci_high),
                m_dat,
                width = 0.06,
                size = 3) +
  scale_x_continuous(breaks = c(0.4, 0.6), limits = c(0.2, 0.8),
                     expand = c(0, 0)) +
  scale_y_continuous(limits = c(-0.5, 2.5),
                     breaks = c(0.3, 1.1, 1.9),
                     expand = c(0, 0)) + 
  theme_sim()


ggsave(fp, filename = '~/Desktop/fp.pdf', width = 4, height = 3)
ggsave(rp, filename = '~/Desktop/rp.pdf', width = 4, height = 3)
ggsave(ep, filename = '~/Desktop/ep.pdf', width = 4, height = 3)

library(grid)
library(gridExtra)
layout <- rbind(c(1, 1),
                c(2, 5),
                c(3, 6),
                c(4, 7))

layout2 <- rbind(c(1, 4),
                c(2, 5),
                c(3, 6))

font <- "Helvetica Neue"
tit <- grid.text("DeclareDesign", gp=gpar(fontfamily = font, cex=6))
ft <- grid.text("fabricatr", gp=gpar(fontfamily = font, cex=4))
rt <- grid.text("randomizr", gp=gpar(fontfamily = font, cex=4))
et <- grid.text("estimatr", gp=gpar(fontfamily = font, cex=4))
format(ft, core.just="left")
grid.arrange(grobs = list(fp, rp, ep, ft, rt, et), layout_matrix = layout2, widths = 1:2)
