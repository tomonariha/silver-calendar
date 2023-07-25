<template>
  <div class="rounded my-2 settings">
    <section>
      <h2 class="h2 fs-5 my-4">条件から勤務予定を設定する</h2>
      <Confirm
        v-bind:showConfirm="Boolean(confirmedSetting)"
        v-bind:message="'削除します。よろしいですか？'"
        v-on:execution="deleteSetting(confirmedSetting.id)"
        v-on:cancel="cancelConfirm">
      </Confirm>
      <div class="settings-area">
        <div class="content-center my-2" v-if="!(settings.length > 0)">
          <p class="have-no-settings my-2 fs-5">
            まだ条件がありません。条件を作成しましょう。
          </p>
          <br>
          <button
            class="btn btn-primary m-2 new-settings-button"
            v-on:click="newSetting()">
            条件を作る
          </button>
        </div>
        <div v-else>
          <div v-for="setting in slicedSettings" :key="setting.id" class="each-setting my-2 rounded">
            <p
              class="setting-periods m-2 fs-6 rounded"
              v-bind:class="{ selected: selectedSetting === setting }">
              {{ toJapaneseDate(setting.period_start_at) }} 〜 {{ toJapaneseDate(setting.period_end_at) }}
            </p>
            <div class="schedules-view m-2">
              <span>日:</span>
              <ScheduleIcon v-bind:schedule="setting.schedule_of_sunday">
              </ScheduleIcon>
              <span>月:</span>
              <ScheduleIcon v-bind:schedule="setting.schedule_of_monday">
              </ScheduleIcon>
              <span>火:</span>
              <ScheduleIcon v-bind:schedule="setting.schedule_of_tuesday">
              </ScheduleIcon>
              <span>水:</span>
              <ScheduleIcon v-bind:schedule="setting.schedule_of_wednesday">
              </ScheduleIcon>
              <span>木:</span>
              <ScheduleIcon v-bind:schedule="setting.schedule_of_thursday">
              </ScheduleIcon>
              <span>金:</span>
              <ScheduleIcon v-bind:schedule="setting.schedule_of_friday">
              </ScheduleIcon>
              <span>土:</span>
              <ScheduleIcon v-bind:schedule="setting.schedule_of_saturday">
              </ScheduleIcon>
            </div>
            <div class="setting-button-area m-2">
              <button
                v-on:click="editSetting(setting)"
                class="btn btn-sm inconspicuous-button ms-1">
                編集
              </button>
              <button
                v-on:click="reflectSetting(setting)"
                class="btn btn-sm btn-primary ms-1">
                適用
              </button>
              <span v-on:click="confirmDialog(setting)" class="delete-button ms-1"
                >削除</span
              >
            </div>
          </div>
          <Pagenation
            v-bind:array="settings"
            v-bind:pageLimit="pageLimit"
            v-bind:currentPage="currentPage"
            v-bind:displayRange="displayRange"
            v-on:updateCurrentPage="updateCurrentPage"
            v-on:increasePage="increasePage"
            v-on:decreasePage="decreasePage">
          </Pagenation>
          <div class="d-flex justify-content-center">
            <button
              class="btn btn-primary m-2 new-settings-button"
              v-on:click="newSetting()">
              新しい条件を作る
            </button>
            <button class="btn btn-primary reflect-all-setting-button m-2" v-on:click="reflectAllSettings()">
              条件を一括適用
            </button>
          </div>
        </div>
      </div>
      <SettingForm
        v-bind:showSettingForm="showSettingForm"
        v-bind:year="props.year"
        v-bind:setting="selectedSetting"
        v-on:close="closeSettingModal">
      </SettingForm>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, inject } from 'vue'
import Confirm from './confirm.vue'
import Pagenation from './pagenation.vue'
import { useToast } from 'vue-toastification'
import { FetchRequest } from '@rails/request.js'
import ScheduleIcon from './scheduleIcon.vue'
import SettingForm from './settingForm.vue'

const { settings, deleteFromSettings } = inject('settings')
const { toJapaneseDate } = inject('dateMethods')
const selectedSetting = ref(null)
const toast = useToast()
const props = defineProps({
  year: Number
})
const emit = defineEmits(['reflect', 'reflectAll'])
const showSettingForm = ref(false)
function closeSettingModal() {
  showSettingForm.value = false
}

async function deleteSetting(id) {
  cancelConfirm()
  const request = new FetchRequest(
    'delete',
    `api/v1/calendars/${props.year}/settings/${id}`
  )
  const response = await request.perform()
  if (response.ok) {
    toast('削除しました')
    deleteFromSettings(id)
  }
}
function newSetting() {
  selectedSetting.value = null
  showSettingForm.value = true
}
function reflectSetting(setting) {
  emit('reflect', setting)
}
function reflectAllSettings() {
  emit('reflectAll')
}
function editSetting(setting) {
  selectedSetting.value = setting
  showSettingForm.value = true
}

// 確認ダイアログ
const confirmedSetting = ref(null)
function confirmDialog(setting) {
  confirmedSetting.value = setting
}
function cancelConfirm() {
  confirmedSetting.value = null
}
// ページング
const currentPage = ref(1)
const pageLimit = 5
const displayRange = 1
const slicedSettings = computed(() => {
  let start = (currentPage.value - 1) * pageLimit
  let end = start + pageLimit
  return settings.value.slice(start, end)
})
function updateCurrentPage(newPage) {
  currentPage.value = newPage
}
function increasePage() {
  currentPage.value += displayRange + 1
}
function decreasePage() {
  currentPage.value -= displayRange + 1
}
</script>

<style scoped>
.each-setting {
  border: solid 1px lightgray;
}
.new-settings-button {
  width: 200px;
}
.have-no-settings {
  display: inline-block;
  vertical-align: middle;
}
#specified_total_days {
  width: 60px;
}
.schedule-label {
  width: 68px;
}
.error-area {
  background: #ffbeda;
  border: 1px solid #ff5192;
}
.reflect-all-setting-button {
  width: 180px;
}
</style>
