/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-Array/edit/main/Array.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

Array.Prototype.DefineProp('FindAll', { Call: ARRAY_FIND_ALL })
/**
 * @description - Iterates an array passing each set value to a callback function. If the callback
 * function returns nonzero, the item and/or its index are adday to a separate array.
 * @param {Array} Arr - The array to search. If calling this method from an array instance, skip
 * this parameter completely, don't leave a space for it.
 * @param {Func|BoundFunc|Closure} Callback - The function to execute on each element in the array.
 * The function should return a nonzero value when the condition is met. The function can accept
 * one to three parameters:
 * - The current element being processed in the array.
 * - [Optional] The index of the current element being processed in the array.
 * - [Optional] The array find was called upon.
 * @param {Boolean} [IncludeIndices=false] - If true, the index of the element is included in the
 * result array.
 * @param {Boolean} [IncludeItems=true] - If true, the element is included in the result array.
 * @returns {Array} - An array containing the items and/or indices that satisfy the condition.
 * If both `IncludeIndices` and `IncludeItems` are true, the items in the array are objects with
 * properties { Index, Item }.
 */
ARRAY_FIND_ALL(Arr, Callback, IncludeIndices := false, IncludeItems := true) {
    Result := []
    Result.Capacity := Arr.Length
    if IncludeIndices {
        if IncludeItems
            Set := (Item) => Result.Push({ Index: A_Index, Item: Item })
        else
            Set := (*) => Result.Push(A_Index)
    } else if IncludeItems
        Set := (Item) => Result.Push(Item)
    else
        throw Error('At least one or both of ``IncludeIndices`` and ``IncludeItems`` must be set.', -1)
    for Item in Arr{
        if IsSet(Item) && Callback(Item, A_Index, Arr)
            Set(Item)
    }
    Result.Capacity := Result.Length
    return Result.Length ? Result : ''
}
