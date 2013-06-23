
-module(ss_util).





-export([

    merge_settings/2

]).





merge_settings(S1, S2)

    when is_list(S1),
         is_list(S2) ->

    lists:ukeymerge(1, lists:ukeysort(1, S1), lists:ukeysort(1, S2) ).

