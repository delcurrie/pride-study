<?php

$month = $year = 0;

if (!empty($_GET['month'])) {
    $month = (int) $_GET['month'];
}

if (!empty($_GET['year'])) {
    $year = (int) $_GET['year'];
}

if ($year == 0) $year = date('Y');
if ($month == 0) $month = date('n');

$next_month = $month + 1;
$next_month_year = $year;
if ($next_month > 12) {
    $next_month = 1;
    $next_month_year = $year + 1;
}

$prev_month = $month - 1;
$prev_month_year = $year;
if ($prev_month < 1) {
    $prev_month = 12;
    $prev_month_year = $year - 1;
}

$dateObj   = DateTime::createFromFormat('!m', $month);
$month_name = $dateObj->format('F');
?>
<div class="calendar__header">
    <a href="#" class="calendar__month-toggle calendar__month-toggle--previous js-calendar-prev-month" data-month="<?php echo $prev_month;?>" data-year="<?php echo $prev_month_year;?>"></a>
    <a href="#" class="calendar__month-toggle calendar__month-toggle--next js-calendar-next-month" data-month="<?php echo $next_month;?>" data-year="<?php echo $next_month_year;?>"></a>
    <div class="calendar__header__month">
        <span><?php echo $month_name; ?></span> 
        <?php echo $year; ?>
    </div>
</div>
<div class="calendar__dates">
    <?php
    $day = 1;
    $cellsInRow = 7;
    for ($i = 1; $i <= 35; $i++) {
        if (in_array($i, array(1,8,15,22,29))) {
            echo '<div class="calendar__dates__row">';
        }
        
        if ($i <= cal_days_in_month(CAL_GREGORIAN, $month, $year)) {
            echo "<a href='#' class='js-calendar-date calendar-date' data-day='{$i}' data-month='{$month}' data-year='{$year}'>{$i}</a>";
        } else {
            echo "<a href='#' class='js-calendar-date calendar-date calendar-date--muted' data-day='{$day}' data-month='{$next_month}' data-year='{$next_month_year}'>{$day}</a>";
            $day++;
        }

        if (in_array($i, array(7,14,21,28))) {
            echo "</div>";
        }
    }
    ?>
</div>