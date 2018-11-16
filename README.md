# final-year-project
In this project, I aim at applying transfer learning on EEG in order to show significant differences between Parkinson's Disease patients and normal control and build classification model. 
Dr. X WH (though not obtained the degree yet) is working together with me on this topic. 
He is focusing on data augmentation based on GAN. 
The dataset we are using is from [Pred+ct](http://predict.cs.unm.edu/). 
The raw data has a size nearly 122.2GB. 
Notice that so called 'raw data' in our project is not that raw: there are some little changes including rename 8010, 8060, 8070 to 915, 916, 917 respectively and rename the data folders. 
And some data should be deprecated.

## Week 1
In fact we have been working here for a while. 
There should be 'Week 0', 'Week -1', ... , 'Week -9'.
We had a discussion several days ago and based on the dicisions we made I did some preprocessing.

We decided to select **channels around Cz (Pz, Cz, Fz, P3, C3, F3, P4, C4, F4)** as we believe this region is greatly related to cognitive functions.

Why hdf5 files?

Because when I tried to save them as .mat files, the size of the file was strangely huge.
I didn't spend time finding the reason, and hdf5 is a second choice as a bridge between Matlab and Python.

## Week 2
The disappointing thing is that there is always some trivia in the final year thus I cannot fully focus on the project. 
This week I tried to build models and the dataloader. 
Dataloader is always something bloated. 
In the past, I built it and ended up with too many parameters. 
This time I tried to make it as light as possible but it seems that I failed to make differences.

## Week 3
In the summer I saw significant inter-subject differences using VAE dimensionality reduction on Schizophrenia dataset.
This Week I tried to use siamese network to classify the data according to the subjects.
To my surprise, there is no difference at all.
It can be good news: we no longer need to consider about inter-subject differences.
But I think it is **BAD NEWS: maybe there is no difference in distributions at all and neural networks won't learn anything!**
Just wait and see.
