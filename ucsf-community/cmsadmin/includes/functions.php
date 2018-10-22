<?php

class nav {

    private $nav = array();

    function __construct($nav) {
        $this->nav = (array)$nav;
        $this->setCurrent();
        $this->build($this->nav);
    }

    private function build($nav, $parent = false) {
        foreach($nav as $i => $item) {
            if (!$item['url'])
            $item['url'] = '#';

            if ($i === 0) {
                ?>
                <ul class="<?php echo ($parent['current']?' in ':''); ?>nav nav-stacked">
                    <?php
                }
                ?>
                <li <?php echo ($item['current']?'class="active"':'') ?>>
                <a href="<?php echo $item['url']; ?>" class="<?php echo ($item['current']?' in ':''), ($item['children']?' dropdown-collapse ':''); ?>">
                    <?php
                    if ($parent) {
                        ?>
                        <i class="icon-caret-right"></i>
                        <?php
                    }
                    ?>
                    <img class="<?php echo $item['icon']; ?> svg" src="<?php echo $item['src']; ?>">
                    <span><?php echo $item['name']; ?></span>
                    <?php
                    if ($item['children']) {
                        ?>
                        <i class='icon-angle-down angle-down'></i>
                        <?php
                    }
                    ?>
                </a>
                <?php
                if ($item['children'])
                $this->build($item['children'], $item);
                ?>
            </li>
            <?php
        }
        ?>
    </ul>
    <?php
}

private function setCurrent() {
    foreach ($this->nav as &$nav) {
        $nav = $this->isCurrent($nav);
    }
}

private function isCurrent($nav) {
    if ($nav['children']) {
        foreach ($nav['children'] as $i => $child) {
            $nav['children'][$i] = $this->isCurrent($child);
            if ($nav['children'][$i]['current'])
            $nav['current'] = true;
        }
    } else {
        $nav['current'] = $this->compareURL($nav['url']) || $this->compareURL($nav['alias']);
    }
    return $nav;
}

private function compareURL($url) {
    if ($url == '')
    return false;

    if (is_array($url)) {
        foreach ($url as $u) {
            $valid = $this->compareURL($u);
            if ($valid)
            return true;
        }
        return false;
    }

    static $current_basename, $current_path_info;
    if (!$current_path_info) {
        $current_basename = basename($_SERVER['SCRIPT_NAME']);
        $current_path_info = parse_url($_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI']);
    }

    $url_info = parse_url($url);
    $query_matched = false;
    if ($current_path_info['query'] == $url_info['query'] || $url_info['query'] == '' || $url_info['query'] == '?') {
        $query_matched = true;
    } else {
        $query = parse_str($url_info['query'], $params);
        $params_count = count($params);
        $matched = 0;
        foreach ($params as $key => $value) {
            if ($_GET[$key] == $value) {
                $matched++;
            }
        }
        if ($matched == $params_count) {
            $query_matched = true;
        }
    }

    return ($current_basename == basename($url_info['path']) && $query_matched);
}

}

function geolocateAddress($address_url) {
    $url = "http://maps.google.com/maps/geo?q=".urlencode($address_url)."&output=json&oe=utf8&sensor=false&key=KEY";
    $url = "http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=".urlencode($address_url);
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_HEADER, 0);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    $response = curl_exec($ch);
    curl_close($ch);

    $json = json_decode($response, true);
    return $json;
}

function getVideoInfoFromLink($link) {
    if (empty($link))
    return array();

    if (strpos($link, 'youtube.com') !== false) {
        preg_match('/v\=([^\&\=]+)/', $link, $matches);
        $id = $matches[1];
        return array(
            'type' => 'youtube',
            'id' => $id
        );
    } elseif (strpos($link, 'youtu.be') !== false) {
        $link = preg_replace('/(.*)youtu\.be\//', '', $link);
        preg_match('/([^\/\?]+)/', $link, $matches);
        $id = $matches[1];
        return array(
            'type' => 'youtube',
            'id' => $id
        );
    } elseif (strpos($link, 'vimeo') !== false) {
        $link = preg_replace('/(.*)vimeo.com\//', '', $link);
        preg_match('/([^\/\?]+)/', $link, $matches);
        $id = $matches[1];
        return array(
            'type' => 'vimeo',
            'id' => $id
        );
    }
    return array();
}

function getVideoEmbedFromLink($link, $width = 500, $height = 281, $autoplay = false, $jsapi = false) {
    if (empty($link))
    return '';
    $info = getVideoInfoFromLink($link);
    switch ($info['type']) {
        case 'youtube':
        return '<iframe'.($width != ''?' width="'.$width.'"':'').($height != ''?' height="'.$height.'"':'').($jsapi?' id="videoplayer"':'').' src="http://www.youtube.com/embed/'.$info['id'].'?rel=0'.($autoplay?'&autoplay=1':'').($jsapi?'&enablejsapi=1':'').'" frameborder="0" allowfullscreen></iframe>';
            break;
            case 'vimeo':
            return '<iframe'.($width != ''?' width="'.$width.'"':'').($height != ''?' height="'.$height.'"':'').($jsapi?' id="videoplayer"':'').' src="http://player.vimeo.com/video/'.$info['id'].'?title=0&amp;byline=0&amp;portrait=0&amp;color=ffffff'.($autoplay?'&amp;autoplay=1':'').($jsapi?'&amp;api=1&player_id=videoplayer':'').'" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>';
                break;
                default:
                return '';
                break;
            }
        }

        function getVideoInfoFromEmbed($embed) {
            if (strpos($embed, 'youtube.com') !== false) {

                switch (true) {

                    case (preg_match('/http:\/\/www.youtube.com\/embed\/([a-zA-Z0-9_-]+)/', $embed, $matches)): {
                        return array(
                            'type' => 'youtube',
                            'id' => $matches[1]
                        );
                        break;
                    }

                    case (preg_match('/http:\/\/www.youtube.com\/v\/([a-zA-Z0-9_-]+)/', $embed, $matches)): {
                        return array(
                            'type' => 'youtube',
                            'id' => $matches[1]
                        );
                        break;
                    }

                    case (preg_match('/http:\/\/www.youtube.com\/apiplayer\?video_id=([a-zA-Z0-9_-]+)/', $embed, $matches)): {
                        return array(
                            'type' => 'youtube',
                            'id' => $matches[1]
                        );
                        break;
                    }

                    default:
                    return false;
                    break;

                }
            } elseif (strpos($embed, 'vimeo.com') !== false) {
                if (preg_match('/http:\/\/player.vimeo.com\/vimeo\/([0-9]+)/', $embed, $matches)) {
                    return array(
                        'type' => 'vimeo',
                        'id' => $matches[1]
                    );
                }
            } else {
                return false;
            }
        }

        function getVideoThumbnailFromInfo($info) {
            if ($info['type'] == 'youtube') {
                $youtube_id = $info['id'];
                $filename = time().md5($youtube_id).'.jpg';
                file_put_contents(DIR_APP_CACHE.$filename, file_get_contents('http://img.youtube.com/vi/'.$youtube_id.'/maxresdefault.jpg'));
                if (filesize(DIR_APP_CACHE.$filename) == 0) {
                    file_put_contents(DIR_APP_CACHE.$filename, file_get_contents('http://img.youtube.com/vi/'.$youtube_id.'/0.jpg'));
                }
                if (getimagesize(DIR_APP_CACHE.$filename) !== false) {
                    return $filename;
                }
            } elseif ($info['type'] == 'vimeo') {
                $vimeo_id = $info['id'];
                $xml = simplexml_load_file('http://vimeo.com/api/v2/video/'.$vimeo_id.'.xml');
                $filename = time().md5($vimeo_id).'.jpg';
                file_put_contents(DIR_APP_CACHE.$filename, file_get_contents($xml->video->thumbnail_large));
                if (getimagesize(DIR_APP_CACHE.$filename) !== false) {
                    return $filename;
                }
            }
            return '';
        }

        function formatBytes($bytes, $precision = 2) {
            $units = array('B', 'KB', 'MB', 'GB', 'TB');

            $bytes = max($bytes, 0);
            $pow = floor(($bytes ? log($bytes) : 0) / log(1024));
            $pow = min($pow, count($units) - 1);

            // Uncomment one of the following alternatives
            $bytes /= pow(1024, $pow);
            // $bytes /= (1 << (10 * $pow));

            return round($bytes, $precision) . ' ' . $units[$pow];
        }

        function trimExcerpt($text) {
            $text = str_replace(']]>', ']]&gt;', $text);
            $text = strip_tags($text);
            $excerpt_length = 40;
            $excerpt_more = '...';
            $words = preg_split("/[\n\r\t ]+/", $text, $excerpt_length + 1, PREG_SPLIT_NO_EMPTY);
            if (count($words) > $excerpt_length) {
                array_pop($words);
                $text = implode(' ', $words);
                $text = $text . $excerpt_more;
            } else {
                $text = implode(' ', $words);
            }
            return $text;
        }

        function buildAdminBreadcrumb($breadcrumb = array()) {
            ?>

            <ul class="clearfix Breadcrumb">
                <?php
                $total_crumbs = count($breadcrumb);
                $single_crumb = ($total_crumbs == 1);

                foreach ($breadcrumb as $i => $crumb) {
                    $last_crumb = (($i + 1) == $total_crumbs) && $i > 0;
                    ?>
                    <li>

                        <?php
                        if (!empty($crumb['url'])) {
                            ?>
                            <a href="<?php echo $crumb['url']; ?>"<?php echo ($single_crumb?' class="Single"':($last_crumb?' class="Current"':'')); ?>><?php echo $crumb['name']; ?></a>
                            <?php
                        } else {
                            ?>
                            <a<?php echo ($last_crumb?' class="Current"':''); ?>><?php echo $crumb['name']; ?></a>
                            <?php
                        }
                        ?>
                    </li>
                    <?php
                }
                ?>
                <li class="Right"><a href="logout.php">Logout</a></li>
            </ul>

            <?php
        }

        function resize_image($current_image_name, $current_image_location, $new_folder, $max_width, $max_height, $crop=false, $generate_new_name=false, $im_custom='') {

            /*$IMCropSizes = array(
            array(
            'name' => 'Center',
            'gravity' => 'Center'
        ),
        array(
        'name' => 'Middle Left',
        'gravity' => 'West'
    ),
    array(
    'name' => 'Middle Right',
    'gravity' => 'East'
),
array(
'name' => 'Top Center',
'gravity' => 'North'
),
array(
'name' => 'Top Left',
'gravity' => 'NorthWest'
),
array(
'name' => 'Top Right',
'gravity' => 'NorthEast'
),
array(
'name' => 'Bottom Center',
'gravity' => 'South'
),
array(
'name' => 'Bottom Left',
'gravity' => 'SouthWest'
),
array(
'name' => 'Bottom Right',
'gravity' => 'SouthEast'
)
);*/

$image_extension = strtolower(substr($current_image_name, strrpos($current_image_name, '.') + 1));
$split_image_name = array();
$split_image_name[0] = substr($current_image_name, 0, strrpos($current_image_name, '.') - 1);
$split_image_name[1] = $image_extension;

if ($generate_new_name === true) {
    $current_image_name = makeFilenameSafe($split_image_name[0]).'.'.$split_image_name[1];
    $split_image_name = explode('.', $current_image_name, 2);
}

if (!is_writable($new_folder)) {
    return false;
}

if (empty($max_width) && empty($max_height)) {
    return false;
}

$image_size = getimagesize($current_image_location);
$current_image_width = $image_size[0];
$current_image_height = $image_size[1];
if (
($current_image_width == $max_width && $current_image_height == $max_height)
||
(empty($max_height) && $current_image_width == $max_width)
||
(empty($max_width) && $current_image_height == $max_height)
) {
    // Move the image
    copy($current_image_location, $new_folder . $current_image_name);
    return $current_image_name;
}

if (defined('USE_IMAGEMAGICK') && USE_IMAGEMAGICK === true) {

    if (!empty($crop)) {

        if ($crop === true)
        $crop = 'Center';


        $ratio = $current_image_width / $current_image_height;

        if ($max_width/$max_height > $ratio) {
            $new_height = round($max_width / $ratio);
            $new_width = round($max_width);
        } else {
            $new_width = round($max_height * $ratio);
            $new_height = round($max_height);
        }
        exec('convert '.$current_image_location.' -resize '.$new_width.'x'.$new_height.' -gravity '.$crop.' -crop '.$max_width.'x'.$max_height.'+0+0 '.(!empty($im_custom)?$im_custom.' ':'').$new_folder . $current_image_name);
    } else {
        exec('convert '.$current_image_location.' -resize '.(!empty($max_width)?$max_width:'').'x'.(!empty($max_height)?$max_height:'').(!empty($max_width) && !empty($max_height)?'\>':'').' '.(!empty($im_custom)?$im_custom.' ':'').$new_folder . $current_image_name);
    }

} else {

    switch ($image_extension) {
        case 'gif':
            $image = imagecreatefromgif($current_image_location);
            break;
            case 'jpeg':
            case 'jpg':
            $image = imagecreatefromjpeg($current_image_location);
            break;
            case 'png':
            $image = imagecreatefrompng($current_image_location);
            break;
            default:
            return false;
        }

        $current_image_width = imagesx($image);
        $current_image_height = imagesy($image);

        if ($max_width > $current_image_width) {
            $max_width = $current_image_width;
        }
        if ($max_height > $current_image_height) {
            $max_height = $current_image_height;
        }

        $ratio = $current_image_width / $current_image_height;

        if (!empty($crop)) {

            if (empty($max_width) || empty($max_height)) {
                return false;
            }

            if ($max_width/$max_height > $ratio) {
                $new_height = round($max_width / $ratio);
                $new_width = round($max_width);
            } else {
                $new_width = round($max_height * $ratio);
                $new_height = round($max_height);
            }

            $x_mid = $new_width / 2;
            $y_mid = $new_height / 2;

            if ($image_extension == 'gif') {
                $image_holder = imagecreate($new_width, $new_height);
            } else {
                $image_holder = imagecreatetruecolor($new_width, $new_height);
            }

            if (($image_extension == 'gif') || ($image_extension == 'png')) {
                $trnprt_indx = imagecolortransparent($image);
                if ($trnprt_indx >= 0) {
                    $trnprt_color = imagecolorsforindex($image, $trnprt_indx);
                    $trnprt_indx = imagecolorallocate($image_holder, $trnprt_color['red'], $trnprt_color['green'], $trnprt_color['blue']);
                    imagefill($image_holder, 0, 0, $trnprt_indx);
                    imagecolortransparent($image_holder, $trnprt_indx);
                    imagetruecolortopalette($image_holder, true, imagecolorstotal($image) );
                } elseif ($image_extension == 'png') {
                    imagealphablending($image_holder, false);
                    $color = imagecolorallocatealpha($image_holder, 0, 0, 0, 127);
                    imagefill($image_holder, 0, 0, $color);
                    imagesavealpha($image_holder, true);
                }
            }
            imagecopyresampled($image_holder, $image, 0, 0, 0, 0, $new_width, $new_height, $current_image_width, $current_image_height);

            if ($image_extension == 'gif') {
                $new_image = imagecreate($max_width, $max_height);
            } else {
                $new_image = imagecreatetruecolor($max_width, $max_height);
            }
            if (($image_extension == 'gif') || ($image_extension == 'png')) {
                $trnprt_indx = imagecolortransparent($image_holder);
                if ($trnprt_indx >= 0) {
                    $trnprt_color = imagecolorsforindex($image_holder, $trnprt_indx);
                    $trnprt_indx = imagecolorallocate($new_image, $trnprt_color['red'], $trnprt_color['green'], $trnprt_color['blue']);
                    imagefill($new_image, 0, 0, $trnprt_indx);
                    imagecolortransparent($new_image, $trnprt_indx);
                    imagetruecolortopalette($new_image, true, imagecolorstotal($image_holder) );
                } elseif ($image_extension == 'png') {
                    imagealphablending($new_image, false);
                    $color = imagecolorallocatealpha($new_image, 0, 0, 0, 127);
                    imagefill($new_image, 0, 0, $color);
                    imagesavealpha($new_image, true);
                }
            }
            imagecopyresampled($new_image, $image_holder, 0, 0, ($x_mid-($max_width/2)), ($y_mid-($max_height/2)), $max_width, $max_height, $max_width, $max_height);

            imagedestroy($image);
            imagedestroy($image_holder);

        } else {

            if (empty($max_height)) {
                $new_width = round($max_width);
                $new_height = round($max_width / $ratio);
            } elseif (empty($max_width)) {
                $new_height = round($max_height);
                $new_width = round($max_height * $ratio);
            } else {
                $scale = min($max_width/$current_image_width, $max_height/$current_image_height);
                $new_width = floor($scale*$current_image_width);
                $new_height = floor($scale*$current_image_height);
            }

            if ($image_extension == 'gif') {
                $new_image = imagecreate($new_width, $new_height);
            } else {
                $new_image = imagecreatetruecolor($new_width, $new_height);
            }
            if (($image_extension == 'gif') || ($image_extension == 'png')) {
                $trnprt_indx = imagecolortransparent($image);
                if ($trnprt_indx >= 0) {
                    $trnprt_color = imagecolorsforindex($image, $trnprt_indx);
                    $trnprt_indx = imagecolorallocate($new_image, $trnprt_color['red'], $trnprt_color['green'], $trnprt_color['blue']);
                    imagefill($new_image, 0, 0, $trnprt_indx);
                    imagecolortransparent($new_image, $trnprt_indx);
                    imagetruecolortopalette($new_image, true, imagecolorstotal($image) );
                } elseif ($image_extension == 'png') {
                    imagealphablending($new_image, false);
                    $color = imagecolorallocatealpha($new_image, 0, 0, 0, 127);
                    imagefill($new_image, 0, 0, $color);
                    imagesavealpha($new_image, true);
                }
            }
            imagecopyresampled($new_image, $image, 0, 0, 0, 0, $new_width, $new_height, $current_image_width, $current_image_height);
            imagedestroy($image);

        }

        switch($image_extension) {
            case 'jpg':
            case 'jpeg':
            imagejpeg($new_image, $new_folder . $current_image_name, 100); // Best Quality
            break;

            case 'gif':
                imagegif($new_image, $new_folder . $current_image_name);
                break;

                case 'png':
                imagesavealpha($new_image, true);
                imagepng($new_image, $new_folder . $current_image_name, 0); // No Compression
                break;
            }

            imagedestroy($new_image);

        }

        if ($image_extension == "png") {
            exec(DIR_ROOT . 'cmsadmin/optipng-0.7.4/src/optipng/optipng "'.$new_folder . $current_image_name.'"');
        }

        return $current_image_name;

    }

    function resizeContentImage($class, $filename, $sizes) {
        if (awsEnabled === true)
        $s3 = new S3(awsAccessKey, awsSecretKey);

        foreach ($sizes as $size) {
            $height = (int)$size['height'];
            $width = (int)$size['width'];
            $crop = (int)$size['crop'];
            if (isset($size['folder'])) {
                $folder = $size['folder'];
            } else {
                $folder = $size['width'].'x'.$size['height'];
            }
            if (resize_image($filename, DIR_APP_CACHE.$filename, call_user_func(array($class, 'getImageFolder'), $folder, 'path'), $width, $height, $crop)) {
                if (awsEnabled === true) {
                    if ($s3->putObjectFile(call_user_func(array($class, 'getImageFolder'), $folder, 'path') . $filename, awsBucketName, call_user_func(array($class, 'getImageFolder'), $folder, 's3path') . $filename, S3::ACL_PUBLIC_READ)) {
                        @unlink(call_user_func(array($class, 'getImageFolder'), $folder, 'path') . $filename);
                    }
                }
            }
        }
    }

    function uploadFile($field_name, $folder_path, $folder_url, $input_name = false) {
        if (!$input_name)
        $input_name = $field_name.'_file';
        $uploaded_file = $_FILES[$field_name];
        if (isset($uploaded_file) && is_uploaded_file($uploaded_file["tmp_name"]) && $uploaded_file["error"] == 0) {
            $fileParts = pathinfo($uploaded_file['name']);
            $filename = time().md5($uploaded_file['name']).'.'.$fileParts['extension'];
            move_uploaded_file($uploaded_file['tmp_name'], $folder_path.$filename);
            ?>
            <div>
                <a href="<?php echo $folder_url . '/' . $filename; ?>" target="_blank">View File</a>
            </div>
            <input type="hidden" name="<?php echo $input_name; ?>" value="<?php echo $filename; ?>" />
            <?php
            @unlink(DIR_APP_CACHE.$filename);
            exit();
        }
    }

    function uploadImage($field_name, $class, $sizes, $input_name = false, $callback = 'default') {

        if (is_array($field_name)) {
            foreach ($field_name as $i => $fn) {
                if (is_array($input_name)) {
                    $this_input_name = $input_name[$i];
                } else {
                    $this_input_name = false;
                }
                uploadImage($fn, $class, $sizes, $this_input_name);
            }
            return;
        }

        if (!$input_name)
        $input_name = $field_name.'_file';
        $uploaded_file = $_FILES[$field_name];
        if (isset($uploaded_file) && is_uploaded_file($uploaded_file["tmp_name"]) && $uploaded_file["error"] == 0) {
            $fileParts = pathinfo($uploaded_file['name']);
            $filename = time().md5($uploaded_file['name']).'.'.$fileParts['extension'];
            move_uploaded_file($uploaded_file['tmp_name'], DIR_APP_CACHE.$filename);
            if (getimagesize(DIR_APP_CACHE.$filename) !== false) {
                resizeContentImage($class, $filename, $sizes);
                @unlink(DIR_APP_CACHE.$filename);

                $preview = false;
                foreach ($sizes as $size) {
                    if ($size['preview']) {
                        $preview = $size;
                        break;
                    }
                }
                if (!$preview) {
                    $preview = $sizes[0];
                }
                if (isset($preview['folder'])) {
                    $preview_folder = $preview['folder'];
                } else {
                    $preview_folder = $preview['width'].'x'.$preview['height'];
                }

                if ($callback == 'default') {
                    $url = call_user_func(array($class, 'getImageFolder'), $preview_folder) . $filename;
                    ?>
                    <img src="<?php echo $url; ?>" />
                    <input type="hidden" name="<?php echo $input_name; ?>" value="<?php echo $filename; ?>" />
                    <?php
                    exit();
                } elseif ($callback) {
                    $return = $callback($filename);
                } else {
                    $return = $filename;
                }
            } else {
                // Cause the file upload to fail
                header("HTTP/1.0 500 Internal Server Error");
                @unlink(DIR_APP_CACHE . $filename);
                die();
            }
        }

        return $return;
    }

    function makeFilenameSafe($filename) {

        $temp = $filename;
        $temp = str_replace(" ", "_", $temp);
        $result = '';
        for ($i=0; $i<strlen($temp); $i++) {
            if (preg_match('([0-9]|[A-Za-z]|_)', $temp[$i])) {
                $result = $result . $temp[$i];
            }
        }

        return $result;
    }

    function generateCsv($data, $delimiter = ',', $enclosure = '"') {
        $handle = fopen('php://temp', 'r+');
        foreach ($data as $line) {
            fputcsv($handle, $line, $delimiter, $enclosure);
        }
        rewind($handle);
        $contents = '';
        while (!feof($handle)) {
            $contents .= fread($handle, 8192);
        }
        fclose($handle);
        return $contents;
    }

    function drawHeaderRow($pages, $title = null) {
        $page_icon = '';
        foreach ($pages as $page) {
            if ($page['icon']) {
                $page_icon = $page['icon'];
            }
        }

        $current_page = end($pages);

        if (!$title) {
            $title = $current_page['name'];
        }
        ?>
        <div class="row">
            <div class="col-sm-12">
                <div class="page-header">
                    <h1 class="pull-left">
                        <i class="<?php echo $page_icon; ?>"></i>
                        <span><?php echo $title; ?></span>
                    </h1>
                </div>
            </div>
        </div>
        <?php
    }


    function showSavedDialogue() {
        ?>
        <div class="row">
            <div class="col-sm-12">
                <div class='alert alert-success alert-dismissable'>
                    <a class="close" data-dismiss="alert" href="#">&times;</a>
                    <h4><i class='icon-ok-sign'></i> Saved!</h4>
                    Content saved successfully
                </div>
            </div>
        </div>
        <?php
    }

    /**
     * [caclulateVotes description]
     * @param  [type] $votes [description]
     * @return [type]        [description]
     */
    function calculateNumberOfVotes($topic_votes, $comment_votes) {

        $number_of_upvotes = 0;
        $number_of_downvotes = 0;

        $all_votes = array(
            $topic_votes,
            $comment_votes
        );

        foreach ($all_votes as $votes) {
            foreach ($votes as $vote) {
                if ($vote['upvotes'] > 0) {
                    $number_of_upvotes += $vote['upvotes'];
                }
                if ($vote['downvotes'] > 0) {
                    $number_of_downvotes += $vote['downvotes'];
                }
            }
        }

        return array(
            'number_of_upvotes' => $number_of_upvotes,
            'number_of_downvotes' => $number_of_downvotes
        );
    }

    /**
     * Get the vote details for a given type (upvotes | downvotes)
     *
     * @param  array $topic_votes
     * @param  array $comment_votes
     * @param  string $type  upvotes | downvotes
     * @return array
     */
    function getVoteDetails($topic_votes, $comment_votes, $type) {

        $vote_details = array();

        foreach ($topic_votes as $vote) {
            if ($vote[$type] > 0) {
                $vote['table'] = 'topics';
                array_push($vote_details, $vote);
            }
        }
        foreach ($comment_votes as $vote) {
            if ($vote[$type] > 0) {
                $vote['table'] = 'comments';
                array_push($vote_details, $vote);
            }
        }
        return $vote_details;
    }

/**
 * pr Convenience debugging function
 * @param  [type] $data [description]
 * @return [type]       [description]
 */
function pr($data) {
    echo "<pre>";
        print_r($data);
    echo "</pre>";
}

/**
 * send email with SendGrid
 * @param  string $to      Email details
 * @param  string $subject Email details
 * @param  string $html    Email details
 * @param  string $from    Email details
 * @return void
 */
function sendemail($to, $subject, $html, $from = null) {

    if ($from == null) {
        $from = EMAIL_FROM;
    }

    $params = array(
            'api_user'  => 'ucsfcommunity',
            'api_key'   => 'cZ9AxsnHvx',
            'to'        => $to,
            'subject'   => $subject,
            'html'      => $html,
            'text'      => strip_tags($html),
            'from'      => $from,
            'fromname'  => EMAIL_FROM_NAME,
        );

    $session = curl_init('https://api.sendgrid.com/api/mail.send.json');
    curl_setopt($session, CURLOPT_POST, true);
    curl_setopt($session, CURLOPT_POSTFIELDS, $params);
    curl_setopt($session, CURLOPT_HEADER, false);
    curl_setopt($session, CURLOPT_RETURNTRANSFER, true);

    $response = curl_exec($session);
    curl_close($session);
    return $response;
}

function intToMonth($int) {
    $months[1] = "Jan";
    $months[2] = "Feb";
    $months[3] = "Mar";
    $months[4] = "Apr";
    $months[5] = "May";
    $months[6] = "Jun";
    $months[7] = "Jul";
    $months[8] = "Aug";
    $months[9] = "Sep";
    $months[10] = "Oct";
    $months[11] = "Nov";
    $months[12] = "Dec";
    return $months[$int];
}

function statsSummary($chart_data = array())
{
    $stats = array();
    $stats['first_month'] = intToMonth($chart_data[0]['m']);
    $stats['first_val'] = (int) $chart_data[0]['count'];
    end($chart_data);
    $end = key($chart_data);
    $stats['last_month'] = intToMonth($chart_data[$end]['m']);
    $stats['last_val'] = (int) $chart_data[$end]['count'];
    $stats['posneg'] = ($stats['first_val'] > $stats['last_val'])?"negative":"positive";

    if ($stats['posneg'] == "positive") {
      if ($stats['first_val'] == 0) {
        $stats['percentage'] = round((100/$stats['first_val'])*$stats['last_val']);
      } else {
        $stats['percentage'] = 100;
      }
    } else {
      if ($stats['first_val'] == 0) {
        $stats['percentage'] = 100;
      } else {
        $stats['percentage'] = 100-round((100/$stats['first_val'])*$stats['last_val']);
      }
    }
    
    return $stats;
}


if (!function_exists('array_column')) {
    /**
     * Returns the values from a single column of the input array, identified by
     * the $columnKey.
     *
     * Optionally, you may provide an $indexKey to index the values in the returned
     * array by the values from the $indexKey column in the input array.
     *
     * @param array $input A multi-dimensional array (record set) from which to pull
     *                     a column of values.
     * @param mixed $columnKey The column of values to return. This value may be the
     *                         integer key of the column you wish to retrieve, or it
     *                         may be the string key name for an associative array.
     * @param mixed $indexKey (Optional.) The column to use as the index/keys for
     *                        the returned array. This value may be the integer key
     *                        of the column, or it may be the string key name.
     * @return array
     */
    function array_column($input = null, $columnKey = null, $indexKey = null)
    {
        // Using func_get_args() in order to check for proper number of
        // parameters and trigger errors exactly as the built-in array_column()
        // does in PHP 5.5.
        $argc = func_num_args();
        $params = func_get_args();
        if ($argc < 2) {
            trigger_error("array_column() expects at least 2 parameters, {$argc} given", E_USER_WARNING);
            return null;
        }
        if (!is_array($params[0])) {
            trigger_error(
                'array_column() expects parameter 1 to be array, ' . gettype($params[0]) . ' given',
                E_USER_WARNING
            );
            return null;
        }
        if (!is_int($params[1])
            && !is_float($params[1])
            && !is_string($params[1])
            && $params[1] !== null
            && !(is_object($params[1]) && method_exists($params[1], '__toString'))
        ) {
            trigger_error('array_column(): The column key should be either a string or an integer', E_USER_WARNING);
            return false;
        }
        if (isset($params[2])
            && !is_int($params[2])
            && !is_float($params[2])
            && !is_string($params[2])
            && !(is_object($params[2]) && method_exists($params[2], '__toString'))
        ) {
            trigger_error('array_column(): The index key should be either a string or an integer', E_USER_WARNING);
            return false;
        }
        $paramsInput = $params[0];
        $paramsColumnKey = ($params[1] !== null) ? (string) $params[1] : null;
        $paramsIndexKey = null;
        if (isset($params[2])) {
            if (is_float($params[2]) || is_int($params[2])) {
                $paramsIndexKey = (int) $params[2];
            } else {
                $paramsIndexKey = (string) $params[2];
            }
        }
        $resultArray = array();
        foreach ($paramsInput as $row) {
            $key = $value = null;
            $keySet = $valueSet = false;
            if ($paramsIndexKey !== null && array_key_exists($paramsIndexKey, $row)) {
                $keySet = true;
                $key = (string) $row[$paramsIndexKey];
            }
            if ($paramsColumnKey === null) {
                $valueSet = true;
                $value = $row;
            } elseif (is_array($row) && array_key_exists($paramsColumnKey, $row)) {
                $valueSet = true;
                $value = $row[$paramsColumnKey];
            }
            if ($valueSet) {
                if ($keySet) {
                    $resultArray[$key] = $value;
                } else {
                    $resultArray[] = $value;
                }
            }
        }
        return $resultArray;
    }
}