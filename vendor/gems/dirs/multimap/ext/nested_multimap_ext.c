#include "ruby.h"

static VALUE rb_nested_multimap_aref(int argc, VALUE *argv, VALUE self)
{
	int i;
	VALUE r, k;

	for (i = 0, r = self, k = TYPE(self); TYPE(r) == k; i++)
		r = (i < argc) ? rb_hash_aref(r, argv[i]) : RHASH(r)->ifnone;

	return r;
}

void Init_nested_multimap_ext() {
	VALUE cNestedMultimap = rb_const_get(rb_cObject, rb_intern("NestedMultimap"));
	rb_define_method(cNestedMultimap, "[]", rb_nested_multimap_aref, -1);
}
