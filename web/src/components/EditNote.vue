<template>
  <div class="field is-horizontal">
    <div class="field-label">
      <label class="label" />
    </div>

    <div class="field-body">
      <div class="field is-grouped">
        <div class="control">
          <input
            v-model="text"
            class="input"
            type="text"
            :disabled="!is_editing"
          >
          <p class="help is-danger">
            {{ errors }}
          </p>
        </div>
        <div class="control">
          <a
            class="button is-info"
            :disabled="is_editing"
            @click="edit()"
          >
            <span class="icon">
              <i class="fas fa-edit" />
            </span>
          </a>
        </div>
        <div class="control">
          <a
            class="button is-warning"
            :disabled="is_editing"
            @click="remove()"
          >
            <span class="icon">
              <i class="fas fa-times" />
            </span>
          </a>
        </div>
        <div class="control">
          <a
            class="button is-primary"
            :disabled="!is_editing"
            @click="save()"
          >
            <span class="icon">
              <i class="fas fa-save" />
            </span>
          </a>
        </div>
        <div class="control">
          <a
            class="button is-light"
            :disabled="!is_editing"
            @click="cancel()"
          >
            <span class="icon">
              <i class="fas fa-ban" />
            </span>
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import notesService from '../api-services/notes.js'

export default {
    props: {
        note: {
            type: Object,
            default: null
        },
        token: {
            type: String,
            default: ''
        },
        onRemove: {
            type: Function,
            default: function () {
                return null
            }
        }
    },
    data: function () {
        return {
            text: '',
            cache: '',
            errors: '',
            is_editing: false
        }
    },
    created: function () {
        this.text = this.note.text
        this.cache = this.note.text
    },
    methods: {
        cancel: function() {
            this.text = this.cache 
            this.errors = ''
            this.is_editing = false
        },
        edit: function() {
            this.is_editing = true
        },
        remove: function() {
            this.onRemove(this.note)
        },
        save: function() {
            this.errors = ''
            if (this.text.length == 0) {
              this.errors = 'Note cannot be empty.'
            } else {
              this.note.text = this.text
              notesService.update(this.note.task_id, this.note.id, this.note, this.token)
                .then(response => {
                  console.log(response.data)
                }).catch(error => {
                  console.log(error)
                  this.error = error
              })
              this.is_editing = false
            }
        },
    }
}
</script>

<style>
</style>