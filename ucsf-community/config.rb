environment = :production

preferred_syntax = :scss
http_path = '/'
css_dir = 'assets/css'
sass_dir = 'assets/sass'
images_dir = 'assets/img'
generated_images_dir = 'assets/img/generated'
javascripts_dir = 'assets/js'
fonts_dir = 'assets/fonts'
relative_assets = true
line_comments = (environment == :production) ? false : :true
output_style = (environment == :production) ? :compressed : :expanded

# Disables Compass automatic cache busting
asset_cache_buster do |http_path, real_path|
  nil
end
