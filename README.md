## Inspiration
Helping visually impaired people find their way onto the train. Inspired by Seiichi Miyake's work on Tenji blocks.

## What it does
Our mobile application guides visually impaired people towards their train door and button using voiceover. The voiceover guides the user by indicating direction.

## How I built it
The application was built using Flutter framework and Dart as well as heroku for the machine learning model.
The camera of the phone feeds the heroku server with images and the model gives us back results.
The results is then received on the smartphone. The application uses voiceover to guide the user based on the results.

## Challenges I ran into
We have never deployed a machine learning model in an app before so it was interesting to see how to go about this problem.
The tflite support on flutter was really complex to wrap our heads around therefore we had to use a heroku server for the prototype.

## Accomplishments that I'm proud of
- Development of a Flutter based application using live ML results based on the smartphone camera feed.
- Deployment of an ML model on heroku.


## What we learned
 - The basics of how computer vision works.
 - How to deploy computer vision models.
 - Learned about tensors.


## What's next for SBB challenge 2: Tenji
It would be nice to further develop this app. The first step would be to get this into the hands of people who might actually need it and see how this impacts them. We can develop as much as we want but if it doesn't correspond to what people need it is useless.