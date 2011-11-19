% gsort-plus.sl is a macro created by John E. Davis to 
% enable sorting of slrn's group list by:
%
%      1. Alphabetical order
%      2. Big 8 first
%      3. Big 8 last
% 
% The public function, 'group_sort', could be called 
% from a startup hook but the macro as seen here is
% bound to the keys: 'Esc s'.
%
% Original post of this macro on news.software.readers:
%   Message-ID: <slrnhb4jiq.22n.jed@aluche.mit.edu>

private define sort_groups_alphabetically ()
{
   variable groups = get_group_order ();
   groups = groups [array_sort(groups)];
   set_group_order (groups);
}

private variable Big8_Groups = 
  ["alt", "comp", "misc", "news", "rec", "sci", "soc", "talk"];

private define slice_groups (hierarchies)
{
   variable
     num_hierarchies = length(hierarchies),
     groups = get_group_order (),
     new_groups = String_Type[length(groups)],
     hierarchy_groups = Array_Type[num_hierarchies+1];
   
   groups = groups[array_sort(groups)];
   variable i, j, k;
   hierarchies = hierarchies + ".";
   _for i (0, num_hierarchies-1, 1)
     {
	variable 
	  hierarchy = hierarchies[i],
	  cmp = array_map (Int_Type, &strncmp, hierarchy, 
			   groups, strlen(hierarchy));

	j = where (cmp, &k);
	hierarchy_groups[i] = groups[k];
	groups = groups[j];
     }
   hierarchy_groups[-1] = groups;
   return hierarchy_groups;
}

private define sort_groups_big8_first ()
{
   variable 
     hierarchy_groups = slice_groups (Big8_Groups),
     groups = String_Type[0], i;
   
   _for i (0, length(hierarchy_groups)-1, 1)
     groups = [groups, hierarchy_groups[i]];
   
   set_group_order (groups);
}

private define sort_groups_big8_last ()
{
   variable 
     hierarchy_groups = slice_groups (Big8_Groups),
     groups, i;

   groups = hierarchy_groups[-1];
   _for i (0, length(hierarchy_groups)-2, 1)
     groups = [groups, hierarchy_groups[i]];

   set_group_order (groups);
}

define group_sort ()
{
   if (0 == is_group_mode ())
     throw UsageError, "group_sort is available only in group mode";

   switch (get_select_box_response ("Sort Groups",
				    "Alphabetically",
				    "Big 8 first",
				    "Big 8 last",
				    3))
     { case 0: sort_groups_alphabetically (); }
     { case 1: sort_groups_big8_first (); }
     { case 2: sort_groups_big8_last (); }
}

definekey ("group_sort", "\es", "group");
