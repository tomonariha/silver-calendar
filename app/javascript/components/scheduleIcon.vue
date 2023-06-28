<template>
  <div class="schedule-icon">
    <span v-if="props.schedule === 'full-time'">
      <img
        class="schedule-icon-small"
        :src="fullTime"
        alt="fullTime"
      />
    </span>
    <span v-else-if="props.schedule === 'morning'">
      <img
        class="schedule-icon-small"
        :src="morning" 
        alt="morning"
      />
    </span>
    <span v-else-if="props.schedule === 'afternoon'">
      <img
        class="schedule-icon-small"
        :src="afterNoon"
        alt="afternoon"
      />
    </span>
    <span v-else-if="props.schedule === 'off'">
      <img
        class="schedule-icon-small"
        :src="off"
        alt="off"
      />
    </span>
    <span v-else>
      <img
        class="schedule-icon-small"
        :src="none"
        alt="none"
      />
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

<style>
.schedule-icon-small {
  width: 20px;
  height: 20px;
}
.schedule-icon {
  display: inline;
}
</style>
