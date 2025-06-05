/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/MapExClass.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

class MapExClass {
    static __New() {
        this.__Item := Map()
    }

    /**
     * @description - Creates a nested MapEx object with the given key if one does not exist for
     * that key, then adds the Name-Value pair to the nested object.
     * @param {String} Key - The key that accesses the nested MapEx object.
     * @param {String} Name - The name of the item to add.
     * @param {*} Value - The value of the item to add.
     * @return {MapEx} - Returns the nested MapEx object.
     * @example
        M := MapEx()
        M.AddToCategory('Foo', 'Bar', 'Baz')
        OutputDebug(M.Get('Foo').Get('Bar')) ; Baz
     */
    static AddToCategory(Key, Name, Value) {
        if !this.__Item.Has(Key)
            this.__Item.Set(Key, MapEx())
        this.__Item.Get(Key).Set(Name, Value)
        return this.__Item.Get(Key)
    }

    /**
     * @description - Creates a nested Array object with the given key if one does not exist for
     * that key, then adds the item to the nested object.
     * @param {String} Key - The key that accesses the nested Array object.
     * @param {*} Value - The item to add.
     * @return {Array} - Returns the nested Array object.
     */
    static AddToList(Key, Value) {
        if !this.__Item.Has(Key)
            this.__Item.Set(Key, [])
        this.__Item.Get(Key).Push(Value)
        return this.__Item.Get(Key)
    }

    /**
     * @description - Similar to `AddToCategory`, except no item is added; only the nested MapEx
     * object is created.
     * @param {String} Key - The key that accesses the nested MapEx object.
     * @return {MapEx} - Returns the nested MapEx object.
     */
    static GetCategoryIf(Key) {
        if !this.__Item.Has(Key)
            this.__Item.Set(Key, MapEx())
        return this.__Item.Get(Key)
    }

    /**
     * @description - If a key exists, assigns the value to `OutValue` then deletes the item. Else, does nothing.
     * @param {String|Number} Key - The item key.
     * @param {VarRef} [OutValue] - The variable to receive the value.
     * @return {Boolean} - Returns 1 if the item was found and deleted, else returns an empty string.
     */
    static DeleteIf(Key, &OutValue?) {
        if this.__Item.Has(Key) {
            OutValue := this.__Item.Get(Key)
            this.__Item.Delete(Key)
            return 1
        }
    }

    /**
     * @description - Gets a value if it exists and returns 1. If the item does not exist and the default
     * is set, gets the default and returns 2. Else returns empty string.
     * @example
        M := MapEx()
        M.Set('Foo', 'Bar')
        if M.GetIf('foo', &Value)
            OutputDebug(Value)
        else
            OutputDebug('Not found') ; Because of CaseSense, this is what we would see.
     * @
     * @param {String|Number} Key - The item key.
     * @param {VarRef} [OutValue] - The variable to receive the value.
     * @return {Integer} - Returns 1 if the item was found, returns 2 if the default was provided,
     * else returns an empty string.
     */
    static GetIf(Key, &OutValue?) {
        if this.__Item.Has(Key) {
            OutValue := this.__Item.Get(Key)
            return 1
        } else if this.__Item.HasOwnProp('Default') {
            OutValue := this.__Item.Default
            return 2
        }
    }

    static Index := 0
    static Add(Grid, Name?) {
        this.__Item.Set(Name := Name ?? (++this.Index), Grid)
        return Name
    }
    static Get(Name) => this.__Item.Get(Name)
    static Delete(Name) => this.__Item.Delete(Name)
    static Set(Name, Value) => this.__Item.Set(Name, Value)
    static Clear() => this.__Item.Clear()
    static Clone() => this.__Item.Clone()
    static Has(Name) => this.__Item.Has(Name)
    static __Enum(VarCount) => this.__Item.__Enum(VarCount)
    static Count => this.__Item.Count
    static Capacity {
        Get => this.__Item.Capacity
        Set => this.__Item.Capacity := Value
    }
    static CaseSense => this.__Item.CaseSense
    static Default {
        Get => this.__Item.Default
        Set => this.__Item.Default := Value
    }
}
