<template>
  <div>
    <img class="schedule-icon-small" :src="fullTime" alt="fullTime" />
    <span>全日勤務</span>
    <img class="schedule-icon-small" :src="morning" alt="morning" />
    <span>午前勤務</span>
    <img class="schedule-icon-small" :src="afterNoon" alt="afternoon" />
    <span>午後勤務</span>
    <img class="schedule-icon-small" :src="off" alt="off" />
    <span>休日</span>
    <img class="schedule-icon-small" :src="paidleave" alt="paidleave" />
    <span>年次有給休暇</span>
  </div>
</template>

<script setup>
import fullTime from '../../assets/images/fulltime.svg?url'
import morning from '../../assets/images/morning.svg?url'
import afterNoon from '../../assets/images/afternoon.svg?url'
import off from '../../assets/images/off.svg?url'
import paidleave from '../../assets/images/paidleave.svg?url'
</script>
