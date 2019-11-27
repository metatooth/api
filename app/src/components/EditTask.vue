<template>
  <section class="section">
    <div class="spacer" />
    <div class="field is-horizontal">
      <div class="field-label">
        <label class="label">Description</label>
      </div>
      <div class="field-body">
        <div class="field">
          <div class="control">
            <input
              v-model="record.description"
              class="input"
              type="text"
            >
          </div>
        </div>
      </div>
    </div>
    <div class="field is-horizontal">
      <div class="field-label">
        <label class="label">Completed On</label>
      </div>
      <div class="field-body">
        <div class="field">
          <div class="control">
            <input
              v-model="completed_on"
              class="input"
              type="text"
            >
          </div>
        </div>
      </div>
    </div>
    <div class="field is-horizontal">
      <div class="field-label">
        <label class="label">Duration (hrs)</label>
      </div> 
      <div class="field-body">
        <div class="control">
          <input
            v-model="duration"
            class="input"
            type="number"
          >
        </div>
      </div>
    </div>
    <div class="field is-grouped is-grouped-centered">
      <p class="control">
        <a
          class="button is-primary"
          :disabled="!isComplete"
          @click="save()"
        >Save</a>
      </p>
      <p class="control">
        <a
          class="button is-light"
          @click="cancel()"
        >Cancel</a>
      </p>
    </div>
    <p class="help is-danger"> 
      {{ error }}
    </p>

    <div class="field is-horizontal">
      <div class="field-label">
        <label class="label">Notes</label>
      </div>
      <div class="field-body" />
    </div>

    <edit-note
      v-for="note in record.notes"
      :key="note.id"
      :note="note"
      :token="token"
      :on-remove="remove"
    />
    
    <div class="field is-horizontal">
      <div class="field-label" />
      <div class="field-body">
        <div class="field is-expanded">
          <div class="field has-addons">
            <div class="control">
              <input
                v-model="text"
                class="input"
                type="text"
              >
            </div>
            <div class="control">
              <a
                class="button is-primary"
                :disabled="isTextBlank"
                @click="add()"
              >Add note</a>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="spacer" />
  </section>
</template>

<script>
import notesService from '../api-services/notes.js'
import tasksService from '../api-services/tasks.js'
import EditNote from './EditNote.vue'

export default {
    components: {
      EditNote
    },
    props: {
        cache: {
            type: Object,
            default: null
        },
        onClose: {
            type: Function,
            default: function () {

            }
        },
        record: {
            type: Object,
            default: null
        },
        token: {
            type: String,
            default: ''
        }
    },
    data: function () {
        return {
            completed_on: '',
            duration: 21600,
            error: '',
            text: ''
        }
    },
    computed: {
        isComplete: function () {
            return (this.completed_on.length == 10 && this.record.description.length > 0 && this.record.duration > 0)
        },
        isTextBlank: function () {
          return (this.text.length == 0)
        }
    },
    created: function () {
      this.duration = this.record.duration / 3600
      this.completed_on = new Date(this.record.completed_on).yyyymmdd()
    },
    methods: {
        add: function () {
            notesService.create(this.record['id'], { 'text': this.text }, this.token)
              .then(response => {
                this.record.notes.push(response.data)
              }).catch(error => {
                console.log(error)
              })
            this.text = ''
        },  
        cancel: function () {
            this.record['completed_on'] = this.cache['completed_on']
            this.record['description'] = this.cache['description']
            this.record['duration'] = this.cache['duration']
            this.onClose()
        },
        remove: function(note) {      
            if (confirm('Delete note "' + note.text + '". Are you sure?')) {
                notesService.destroy(this.record['id'], note.id, this.token)
                    .then(response => {
                        this.record.notes.splice(this.record.notes.indexOf(note), 1)
                    })
                    .catch(error => {
                      console.log(error)
                    })
            }
        },

        save: function () {
            this.errors = ''
            if (!this.validDate(this.completed_on)) {
              this.errors = 'Completed On must be in the format YYYY-MM-DD'
            } else {
              const completed_on = this.completed_on.split('-')
              this.record.completed_on = new Date(completed_on[0], completed_on[1]-1, completed_on[2])   
              this.record.duration = this.duration * 3600
              tasksService.update(this.record['id'], this.record, this.token)
                .then(response => {
                  this.onClose()
                }).catch(error => {
                  console.log(error)
                  this.error = error
              })
            }
        },
        validDate: function(str) {
          const re = /^\d\d\d\d-\d\d-\d\d$/
          return re.test(str)
        }
      }
    }
</script>

<style>

.spacer {
  margin-top: 24px;
}

</style>