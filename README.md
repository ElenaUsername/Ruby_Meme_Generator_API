Meme Generator README.md

arhitecture:
->lib
    ->imagine_procesing.rb              -downloading the imagine in tmp
    ->input_validator.rb                -validate the imagine link and the text
    ->meme_generator.rb                 -place the text on the imagine
->public
    ->memes                             -here are saved all the generated memes
        ->
        ->
        ->.keep                         -to be able to see even if the folder is empty
->spec
    ->fixtures                          -for tests
        ->meme1_result_obtained.jpg
        ->meme1.jpg
    ->lib                               -unit tests for lib folder
        ->imagine_procesing_spec.rb
        ->input_validator_spec.rb
        ->meme_generator_spec.rb
    ->app_spec.rb                       -integration tests for app.rb
    ->spec_helper.rb
->tmp
->.gitignore
->.rspec
->app.rb                                -the main file
->Gemfile
->Gemfile.lock
->README.md

Used rspec for testing, sinatra for demo implementation, mini_magick used for imagine edit.
After the imagine link and text is introduced the user should be redirected(302) else error ocurred(422)


