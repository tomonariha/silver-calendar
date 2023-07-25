<template>
  <div class="schedule-icons">
    <span v-if="props.schedule === 'full-time'">
      <img class="schedule-icon-medium" :src="fullTime" alt="fullTime" />
    </span>
    <span v-else-if="props.schedule === 'morning'">
      <img class="schedule-icon-medium" :src="morning" alt="morning" />
    </span>
    <span v-else-if="props.schedule === 'afternoon'">
      <img class="schedule-icon-medium" :src="afterNoon" alt="afternoon" />
    </span>
    <span v-else-if="props.schedule === 'off'">
      <img class="schedule-icon-medium" :src="off" alt="off" />
    </span>
    <span v-else>
      <img class="schedule-icon-medium" :src="none" alt="none" />
    </span>
  </div>
</template>

<script setup>
import fullTime from '../../assets/images/fulltime.svg?url'
import morning from '../../assets/images/morning.svg?url'
import afterNoon from '../../assets/images/afternoon.svg?url'
import off from '../../assets/images/off.svg?url'
import none from '../../assets/images/none.svg?url'

const props = defineProps({
  schedule: String
})
</script>

<style scoped>
.schedule-icons {
  display: inline;
}
</style>
