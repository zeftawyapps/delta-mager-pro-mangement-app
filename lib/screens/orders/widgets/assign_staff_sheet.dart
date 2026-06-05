import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/users_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/workflow_management_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/user_profile.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';

class AssignStaffSheet extends StatelessWidget {
  final OrderModel order;
  final int currentStepIndex;
  final String organizationId;
  final VoidCallback onAssigned;

  const AssignStaffSheet({
    super.key,
    required this.order,
    required this.currentStepIndex,
    required this.organizationId,
    required this.onAssigned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تعيين الطلب لموظف',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),
          const Text('اختر الموظف المناسب:'),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<
              UsersBloc,
              FeaturDataSourceState<UserViewProfileModel>
            >(
              builder: (context, state) {
                return state.listState.when(
                  init: () {
                    context.read<UsersBloc>().loadUsers(
                      organizationId: organizationId,
                    );
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  success: (users) {
                    if (users == null || users.isEmpty) {
                      return const Center(
                        child: Text('لا يوجد موظفين متاحين'),
                      );
                    }
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(user.username ?? ''),
                          subtitle: Text(user.email ?? ''),
                          trailing: const Icon(Icons.chevron_left),
                          onTap: () {
                            context
                                .read<WorkflowManagementBloc>()
                                .assignTask(
                                  entityType: 'orders',
                                  entryId: order.id,
                                  targetUserId: user.userId,
                                  expectedStepNumber: currentStepIndex,
                                );
                            Navigator.pop(context);
                            onAssigned();
                          },
                        );
                      },
                    );
                  },
                  failure: (error, reload) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(error.message ?? 'Error'),
                        TextButton(
                          onPressed: reload,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
