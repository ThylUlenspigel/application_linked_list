module DList;

@safe
class DList(T) {
    import std.typecons : Flag, No, Yes, Tuple;
    import std.traits : Parameters, isCallable;
    alias DFlag=Flag!(DList.stringof);
    alias Result=Tuple!(T, "value", Flag!"DList", "flag");
    enum Empty=Result(T.init, No.DList);
    static class Element {
        private Element previous;
        private Element next;
        T value;
        this(Element _previous, Element _next,T _value) {
            previous=_previous;
            next=_next;
            value=_value;
        }
        final inout(Result) before() inout nothrow {
            if (previous is null) {
                return Empty;
            }
            return Result(previous.value, Yes.DList);
        }
        final inout(Result) after() inout nothrow {
            if (next is null) {
                return Empty;
            }
            return Result(next.value, Yes.DList);
        }

    }
    protected Element head;
    protected Element tail;

    /++
     Adds an element in the header of the list
     +/
    void push(T e) nothrow {
        // ... Implementation missing
    }

    /++
     Adds an element at the tail of the list
     +/
    void unshift(T v) nothrow {
        // ... Implementation missing
    }

    /++
     Removes the header element from the list
     Returns:
     The header element
     +/
    Result pop() nothrow {
        // ... Implementation missing
    }


    /++
     Removes the tail from the list
     Returns:
     The tail element
     +/
    Result shift() nothrow {
        // ... Implementation missing
    }

    invariant {
        if (head !is null) {
            assert(tail.next is null);
            assert(head.previous is null);
        }
    }

    /++
     Remove element
     Returns:
     The element in the list
     +/
    protected T remove(Element element) nothrow
        in {
            assert(element !is null);
        }
    do {
       // ... Implementation missing        
    }

    /++
     Search template.
     Find v in the list and calls do_func on the found element
     +/
    Result Search(alias do_func)(T v) nothrow if (isCallable!do_func) {
        for(Element iter=head; iter !is null; iter=iter.next) {
            if (iter.value == v) {
                return Result(do_func(iter), Yes.DList);
            }
        }
        return Empty;
    }
    /++
     Replace template
     Find dest in the list and calls do_func on the found element with the src parameter
     +/

    Result Replace(alias do_func)(T dest, const T src) nothrow if (isCallable!do_func) {
        for(Element iter=head; iter !is null; iter=iter.next) {
            if (iter.value == src) {
                return Result(do_func(iter, dest).value, Yes.DList);
            }
        }
        return Empty;
    }

    /++
     Search and removes the value v
     Returns:
     The value on the list
     +/
    Result remove(T v) nothrow {
        return Search!remove(v);
    }

    /++
     Replace value at element
     +/
    protected Element replace(Element element, T v) nothrow {
       // ... Implementation missing
    }

    /+
     Replace dest with src
     +/
    Result replace(T dest, const T src) nothrow {
        return Replace!replace(dest, src);
    }


    /++
     Insert v after element
     +/
    protected Element insert_before(Element element, T v) nothrow {
       // ... Implementation missing
     }

    /++
     Insert v before element
     +/
    protected Element insert_after(Element element, T v) nothrow {
       // ... Implementation missing
    }

    /++
     Insert a src before/after dest decided by the after parameter
     +/
    Result insert(bool after=false)(T dest, T src) nothrow {
        static if (after) {
            return Replace!insert_after(dest, src);
        }
        else {
            return Replace!insert_before(dest, src);
        }
    }

    /++
     Returns:
     A range to the list starting from the head
     +/
    @nogc
    Range opSlice() pure inout nothrow {
        return Range(this.head);
    }

    /++
     Returns:
     A range to the list starting from the tail
     +/
    @nogc
    Range reverse() pure inout nothrow {
        return Range(this.tail);
    }

    /++
     Returns:
     The number of elements in the list
     +/
    @nogc
    size_t length() pure const nothrow {
        import std.range.primitives : walkLength;
        return this[].walkLength;
    }

    /++
     Range of DList
     +/
    struct Range {
        @nogc:
        private Element current;
        @trusted this(const Element start) pure nothrow {
            current=cast(Element)(start);
        }

        Range save() nothrow {
            Range result;
            result.current=current;
            return result;
        }

        pure nothrow {
            bool empty() const {
                return current is null;
            }

            inout(Element) front() inout {
                return current;
            }

            void popFront() {
                if (current !is null) {
                    current=current.next;
                }
            }

            alias back=front;

            void popBack() {
                if (current !is null) {
                    current=current.previous;
                }
            }
        }
    }

    import std.range.primitives : isInputRange, isForwardRange, isBidirectionalRange;

    static assert(isInputRange!Range);
    static assert(isForwardRange!Range);
    static assert(isBidirectionalRange!Range);
}

unittest {
    import std.typecons : Flag, No, Yes;
    import std.algorithm.iteration : each, map;
    import std.algorithm.comparison : equal;
    import std.range : retro;
    import std.array : array;

//    import std.stdio;
    { // Empty list
        auto list=new DList!string;
        assert(list.pop.flag is No.DList);
        assert(list.shift.flag is No.DList);
        assert(list.length is 0);
    }

    { // One element
        { // push
            auto list=new DList!string;
            list.push("first");
            assert(list.length is 1);
            const result=list.pop;
            assert(result.flag is Yes.DList);
            assert(result.value == "first");
        }

        { // shift
            auto list=new DList!string;
            list.unshift("last");
            assert(list.length is 1);
            const result=list.pop;
            assert(result.flag is Yes.DList);
            assert(result.value == "last");
        }
    }

    { // Two elements
        const strings=["first", "second"];
        { // push/ushift (pop/shift)
            auto list=new DList!string;
            strings.each!(a => list.push(a));

            assert(equal(strings.retro, list[].map!(a => a.value)));
            assert(equal(strings, list.reverse.retro.map!(a => a.value)));
            assert(list.length is strings.length);
            foreach_reverse(a; strings) {
                const result=list.pop;
                assert(result.flag is Yes.DList);
                assert(result.value == a);
            }
            assert(list.length is 0);

            list=new DList!string;
            strings.each!(a => list.unshift(a));
            assert(equal(strings, list[].map!(a => a.value)));
            assert(equal(strings.retro, list.reverse.retro.map!(a => a.value)));

            foreach_reverse(a; strings) {
                const result=list.shift;
                assert(result.flag is Yes.DList);
//                writefln("a=%s value=%s", a, result.value);
                assert(result.value == a);
            }
            assert(list.length is 0);
        }

        { // Remove first element
            auto list=new DList!string;
            strings.each!(a => list.unshift(a));
            foreach(e; list[]) {
                if (e.value is strings[0]) {
                    list.remove(e);
                }
            }
            assert(equal(strings[1..$], list[].map!(a => a.value)));
            assert(equal(strings[1..$].retro, list.reverse.retro.map!(a => a.value)));

            list.remove(strings[$-1]);
            assert(list.length is 0);
            assert(list[].empty);
        }

        { // Remove Last element
            auto list=new DList!string;
            strings.each!(a => list.unshift(a));
            foreach(e; list[]) {
                if (e.value is strings[1]) {
                    list.remove(e);
                }
            }
            assert(equal(strings[0..$-1], list[].map!(a => a.value)));
            assert(equal(strings[0..$-1].retro, list.reverse.retro.map!(a => a.value)));

            list.remove(strings[0]);
            assert(list.length is 0);
            assert(list[].empty);
        }
    }


    { // Three elements
        const strings=["first", "second", "third"];

        { // push/ushift (pop/shift)

            auto list=new DList!string;
            strings.each!(a => list.push(a));

            assert(equal(strings.retro, list[].map!(a => a.value)));
            assert(equal(strings, list.reverse.retro.map!(a => a.value)));
            assert(list.length is strings.length);
            foreach_reverse(a; strings) {
                const result=list.pop;
                assert(result.flag is Yes.DList);
                assert(result.value == a);
            }
            assert(list.length is 0);

            list=new DList!string;
            strings.each!(a => list.unshift(a));
            assert(equal(strings, list[].map!(a => a.value)));
            assert(equal(strings.retro, list.reverse.retro.map!(a => a.value)));

            foreach_reverse(a; strings) {
                const result=list.shift;
                assert(result.flag is Yes.DList);
                assert(result.value == a);
            }
            assert(list.length is 0);
        }

        { // Remove first element
            auto list=new DList!string;
            strings.each!(a => list.unshift(a));
            foreach(e; list[]) {
                if (e.value is strings[0]) {
                    list.remove(e);
                }
            }
            assert(equal(strings[1..$], list[].map!(a => a.value)));
            assert(equal(strings[1..$].retro, list.reverse.retro.map!(a => a.value)));

            list.remove(strings[$-1]);
            assert(list.length is 1);
            list.remove(strings[$-2]);
            assert(list.length is 0);
            assert(list[].empty);
        }

        { // Remove Last element
            auto list=new DList!string;
            strings.each!(a => list.unshift(a));
            foreach(e; list[]) {
                if (e.value is strings[$-1]) {
                    list.remove(e);
                }
            }
            assert(equal(strings[0..$-1], list[].map!(a => a.value)));
            assert(equal(strings[0..$-1].retro, list.reverse.retro.map!(a => a.value)));

            list.remove(strings[$-3]);
            assert(list.length is 1);
            assert(equal(strings[1..$-1], list[].map!(a => a.value)));
            assert(equal(strings[1..$-1].retro, list.reverse.retro.map!(a => a.value)));
            list.remove(strings[$-2]);
            assert(list.length is 0);

            assert(list[].empty);
        }

        { // Remove center element
            auto list=new DList!string;
            strings.each!(a => list.unshift(a));

            list.remove(strings[1]);
            assert(list.length is strings.length -1);

            const results=strings[0..1]~strings[2..$];
            assert(equal(results, list[].map!(a => a.value)));
            assert(equal(results.retro, list.reverse.retro.map!(a => a.value)));


        }
    }

    { // remove
        const strings=["first", "second", "third", "fourth", "fifth"];
        { // remove
            auto list=new DList!string;
            strings.each!(a => list.unshift(a));

            { // remove center element
                const mid=list.remove(strings[2]);
                const results=strings[0..2]~strings[3..$];
                assert(equal(results, list[].map!(a => a.value)));
                assert(equal(results.retro, list.reverse.retro.map!(a => a.value)));
                assert(list.length is strings.length-1);
                assert(mid.flag is Yes.DList);
                assert(mid.value == strings[2]);
            }

            { // Remove first element
                const first=list.remove(strings[0]);
                const results=strings[1..2]~strings[3..$];
                assert(equal(results, list[].map!(a => a.value)));
                assert(equal(results.retro, list.reverse.retro.map!(a => a.value)));
                assert(list.length is strings.length-2);
                assert(first.flag is Yes.DList);
                assert(first.value == strings[0]);
            }

            { // Remove last element
                const last=list.remove(strings[$-1]);
                const results=strings[1..2]~strings[3..$-1];
                assert(equal(results, list[].map!(a => a.value)));
                assert(equal(results.retro, list.reverse.retro.map!(a => a.value)));
                assert(list.length is strings.length-3);
                assert(last.flag is Yes.DList);
                assert(last.value == strings[$-1]);
            }

            { // Remove none
                const not_found=list.remove(strings[2]);
                const results=strings[1..2]~strings[3..$-1];
                assert(equal(results, list[].map!(a => a.value)));
                assert(equal(results.retro, list.reverse.retro.map!(a => a.value)));
                assert(list.length is strings.length-3);
                assert(not_found.flag is No.DList);
                assert(not_found.value == "");
            }

        }

        { // Range forward
            auto list=new DList!string;
            strings.each!(a => list.unshift(a));
            auto r=list[];

            assert(r.front.before.flag is No.DList);
            assert(r.front.before.value == "");
            assert(r.front.after.flag is Yes.DList);
            assert(r.front.after.value == strings[1]);

            r.popFront; r.popFront;

            assert(r.front.before.flag is Yes.DList);
            assert(r.front.before.value == strings[1]);
            assert(r.front.after.flag is Yes.DList);
            assert(r.front.after.value == strings[3]);

            r.popFront; r.popFront;

            assert(r.front.before.flag is Yes.DList);
            assert(r.front.before.value == strings[3]);
            assert(r.front.after.flag is No.DList);
            assert(r.front.after.value == "");


        }

        { // Range backward
            auto list=new DList!string;
            strings.each!(a => list.push(a));
            auto r=list.reverse;
            assert(r.back.after.flag is No.DList);
            assert(r.back.after.value == "");
            assert(r.back.before.flag is Yes.DList);
            assert(r.back.before.value == strings[1]);

            r.popBack; r.popBack;

            assert(r.back.after.flag is Yes.DList);
            assert(r.back.after.value == strings[1]);
            assert(r.back.before.flag is Yes.DList);
            assert(r.back.before.value == strings[3]);

            r.popBack; r.popBack;

            assert(r.back.after.flag is Yes.DList);
            assert(r.back.after.value == strings[3]);
            assert(r.back.before.flag is No.DList);
            assert(r.back.before.value == "");
        }


        void replace_test(T)() { // replace
            auto list=new DList!T;
            strings.each!(a => list.unshift(a));
            auto results=strings.dup;

            // writefln("%s", list[].map!(a => a.value));
            { // replace None
                const result=list.replace("none", "not found");
                assert(equal(strings, list[].map!(a => a.value)));
                assert(equal(strings.retro, list.reverse.retro.map!(a => a.value)));
                assert(strings.length is list.length);
                assert(result.flag is No.DList);
                assert(result.value == "");
            }

            { // replace first element
                results[0]="første";
                const result=list.replace(results[0], strings[0]);
                // writefln("%s", list[].map!(a => a.value));
                // writefln("%s", results);

                assert(equal(results, list[].map!(a => a.value)));
                assert(equal(results.retro, list.reverse.retro.map!(a => a.value)));
                assert(strings.length is list.length);
                assert(result.flag is Yes.DList);
                assert(result.value == results[0]);
            }

            { // replace last element
                results[$-1]="fünfte";
                const result=list.replace(results[$-1], strings[$-1]);
                // writefln("%s", list[].map!(a => a.value));
                // writefln("%s", results);

                assert(equal(results, list[].map!(a => a.value)));
                assert(equal(results.retro, list.reverse.retro.map!(a => a.value)));
                assert(strings.length is list.length);
                assert(result.flag is Yes.DList);
                assert(result.value == results[$-1]);

            }

            { // replace center element
                results[2]="в третьих";
                const result=list.replace(results[2], strings[2]);
                // writefln("%s", list[].map!(a => a.value));
                // writefln("%s", results);

                assert(equal(results, list[].map!(a => a.value)));
                assert(equal(results.retro, list.reverse.retro.map!(a => a.value)));
                assert(strings.length is list.length);
                assert(result.flag is Yes.DList);
                assert(result.value == results[2]);
            }
        }

        replace_test!string;
        replace_test!(immutable(string));


        { // Insert before
            auto list=new DList!string;
            strings.each!(a => list.unshift(a));
            auto results=strings.dup;

            { // Insert before none
                const result=list.insert("none", "not found");
                assert(equal(strings, list[].map!(a => a.value)));
                assert(strings.length is list.length);
                assert(result.flag is No.DList);
                assert(result.value == "");

            }

            { // Insert before first element
                results="første"~results;
                const result=list.insert(results[0], strings[0]);

                assert(equal(results, list[].map!(a => a.value)));
                assert(equal(results.retro, list.reverse.retro.map!(a => a.value)));
                assert(results.length is list.length);
                assert(result.flag is Yes.DList);
                assert(result.value == results[0]);
            }

            { // Insert before last element
                results=results[0..$-1]~"fünfte"~results[$-1];
                const result=list.insert(results[$-2], strings[$-1]);
                assert(equal(results, list[].map!(a => a.value)));
                assert(equal(results.retro, list.reverse.retro.map!(a => a.value)));
                assert(results.length is list.length);
                assert(result.flag is Yes.DList);
                assert(result.value == results[$-2]);
            }

            { // Insert before mid element
                results=results[0..3]~"в третьих"~results[3..$];
                const result=list.insert(results[3], strings[2]);
                assert(equal(results, list[].map!(a => a.value)));
                assert(equal(results.retro, list.reverse.retro.map!(a => a.value)));
                assert(results.length is list.length);
                assert(result.flag is Yes.DList);
                assert(result.value == results[3]);
            }
        }

        { // Insert after
            auto list=new DList!string;
            strings.each!(a => list.unshift(a));
            auto results=strings.dup;

            { // Insert before none
                const result=list.insert!true("none", "not found");
                assert(equal(strings, list[].map!(a => a.value)));
                assert(equal(strings.retro, list.reverse.retro.map!(a => a.value)));
                assert(strings.length is list.length);
                assert(result.flag is No.DList);
                assert(result.value == "");

            }

            { // Insert after first element
                results=results[0..1]~"første"~results[1..$];

                const result=list.insert!true(results[1], strings[0]);
                assert(equal(results, list[].map!(a => a.value)));
                assert(equal(results.retro, list.reverse.retro.map!(a => a.value)));
                assert(results.length is list.length);
                assert(result.flag is Yes.DList);
                assert(result.value == results[1]);
            }

            { // Insert after last element
                results~="fünfte";
                const result=list.insert!true(results[$-1], strings[$-1]);
                assert(equal(results, list[].map!(a => a.value)));
                assert(results.length is list.length);
                assert(result.flag is Yes.DList);
                assert(result.value == results[$-1]);
            }

            { // Insert after center element
                results=results[0..4]~"в третьих"~results[4..$];
                const result=list.insert!true(results[4], strings[2]);
                assert(equal(results, list[].map!(a => a.value)));
                assert(results.length is list.length);
                assert(result.flag is Yes.DList);
                assert(result.value == results[4]);
            }
        }
    }
}
