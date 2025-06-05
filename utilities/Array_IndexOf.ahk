/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-Array/edit/main/Array.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

Array.Prototype.DefineProp('IndexOf', { Call: ARRAY_INDEX_OF })
/**
 * @description - Searches an array for the input value.
 * @param {Array} Arr - The array to search. If calling this method from an array instance, skip
 * this parameter completely, don't leave a space for it.
 * @param {Number|String} Item - The value to search for.
 * @param {Integer} [Start=1] - The index to start the search from.
 * @param {Integer} [Length] - The number of elements to search. If unset, the search will continue
 * until the end of the array.
 * @param {Boolean} [StrictType=true] - If true, the search will only return a match if the type of
 * the value in the array matches the type of the input value.
 * @param {Boolean} [CaseSense=true] - If true, the search will be case-sensitive.
 * @returns {Integer} - The index of the first occurrence of the input value in the array. If the
 * value is not found, an empty string is returned.
 */
ARRAY_INDEX_OF(Arr, Item, Start := 1, Length?, StrictType := true, CaseSense := true) {
    if IsObject(Item)
        throw TypeError('Objects cannot be compared by value. Define a hashing function to compare'
        ' objects, or use ``Find`` which searches an array using a callback function.', -1)
    End := IsSet(Length) && Start + Length < Arr.Length ?  Start + Length : Arr.Length
    i := Start - 1
    if CaseSense {
        if StrictType {
            while ++i <= End {
                if Arr.Has(i) && Arr[i] == Item && Type(Arr[i]) == Type(Item)
                    return i
            }
        } else {
            while ++i <= End {
                if Arr.Has(i) && Arr[i] == Item
                    return i
            }
        }
    } else {
        if StrictType {
            while ++i <= End {
                if Arr.Has(i) && Arr[i] = Item && Type(Arr[i]) == Type(Item)
                    return i
            }
        } else {
            while ++i <= End {
                if Arr.Has(i) && Arr[i] = Item
                    return i
            }
        }
    }
}
