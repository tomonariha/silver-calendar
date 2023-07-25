<template>
  <div class="schedule-descriptions my-2">
    <div class="each-schedule-description">
      <img class="schedule-icon-medium" :src="fullTime" alt="fullTime" />
      <span>全日勤務</span>
    </div>
    <div class="each-schedule-description">
      <img class="schedule-icon-medium" :src="morning" alt="morning" />
      <span>午前勤務</span>
    </div>
    <div class="each-schedule-description">
      <img class="schedule-icon-medium" :src="afterNoon" alt="afternoon" />
      <span>午後勤務</span>
    </div>
    <div class="each-schedule-description">
      <img class="schedule-icon-medium" :src="off" alt="off" />
      <span>休日</span>
    </div>
    <div class="each-schedule-description">
      <img class="schedule-icon-medium" :src="paidleave" alt="paidleave" />
      <span>年休</span>
    </div>
  </div>
</template>

<script setup>
import fullTime from '../../assets/images/fulltime.svg?url'
import morning from '../../assets/images/morning.svg?url'
import afterNoon from '../../assets/images/afternoon.svg?url'
import off from '../../assets/images/off.svg?url'
import paidleave from '../../assets/images/paidleave.svg?url'
</script>

<style scoped>
.schedule-descriptions {
  display: flex;
  justify-content: center;
  gap: 8px;
}
.each-schedule-description {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 62px;
  font-size: 14px;
  line-height: 1.2;
  gap: 4px;
}
</style>
