import Component from '@glimmer/component';
import { computed } from '@ember/object';

/**
 * Draws a list of key/value pairs.
 *
 * @param { hash } def - section definition
 * ```javascript
 * {
 *     ... // TODO
 * }
 * ```
 * @module component/oxi-section/keyvalue
 */
export default class OxiSectionKeyvalueComponent extends Component {
    @computed("args.def.data")
    get items() {
        let items = this.args.def.data || [];
        for (const i of items) {
            if (i.format === 'head') { i.isHead = 1 }
        }
        // hide items where value (after formatting) is empty
        // (this could only happen with format 'raw' and empty values)
        return items.filter(item => item.format !== 'raw' || item.value !== '');
    }
}
