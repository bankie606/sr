sr will be a distributed system for processing streams of data


It is [Ryan Lopopolo](http://hyperbo.la)'s 6.UAP aka senior thesis.
He is being supervised by [Martin Rinard](http://people.csail.mit.edu/rinard/).

Most badass configuration tested (boxes represent machines):

```

                  |--------|
                - | worker | 
               /  |--------|
|-----------| /   |--------|
| master    | --- | worker |
| spout     |     |--------|
| fetcher   |     |--------|
| collector | --- | worker |
|-----------| \   |--------|
               \  |--------|
                - | worker |
                  |--------|
```

