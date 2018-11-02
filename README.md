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
We decided to select channels around FCz (FCz, Fz, Cz, FC1, FC2, C1, C2) as we believe this region is greatly related to cognitive functions.
