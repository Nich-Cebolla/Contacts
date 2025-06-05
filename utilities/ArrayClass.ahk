
class ArrayClass {
    static __New() {
        this.__Item := []
    }

    static Clone() => this.__Item.Clone
    static Delete(Index) => this.__Item.Delete(Index)
    static Get(Index) => this.__Item.Get(Index)
    static Has(Index) => this.__Item.Has(Index)
    static InsertAt(Index, Values*) => this.__Item.InsertAt(Index, Values*)
    static Pop() => this.__Item.Pop()
    static Push(Values*) => this.__Item.Push(Values*)
    static RemoveAt(Index, Length := 1) => this.__Item.RemoveAt(Index, Length)
    static __Enum(VarCount) => this.__Item.__Enum(VarCount)
    static Length {
        Get => this.__Item.Length
        Set => this.__Item.Length := Value
    }
    static Capacity {
        Get => this.__Item.Capacity
        Set => this.__Item.Capacity := Value
    }
    static Default {
        Get => this.__Item.Default
        Set => this.__Item.Default := Value
    }
}
